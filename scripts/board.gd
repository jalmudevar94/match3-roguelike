class_name Board
extends Node2D

const GEM_SCENE = preload("res://scenes/Gem.tscn")
const BOARD_SIZE = 6
const TILE_SIZE = 80
const BOARD_OFFSET = Vector2(50, 50)
const MAX_COLOR_PROBABILITY: float = 0.5
const ROLLABLE_SPECIAL_TYPES: Array[Gem.SpecialType] = [
	Gem.SpecialType.BONUS,
	Gem.SpecialType.MULTI
]

var special_type_chances: Dictionary = {}
var initial_special_type_chances: Dictionary = {}

var board = []
var match_detector: MatchDetector = MatchDetector.new()
var selected_gem = null
var is_resolving := true
var input_enabled := true
var last_swapped_gem_a: Gem = null
var last_swapped_gem_b: Gem = null
var pending_bomb_detonations: Array[Gem] = []
var reverse_gravity: bool = false
var bomb_required_triggers: int = 1
var bomb_trigger_counts: Dictionary = {}

var initial_color_weights: Array[int]
var initial_bomb_on_match_4: bool
var initial_bomb_on_match_5: bool
var initial_bomb_on_match_L: bool
var initial_bomb_on_match_T: bool
var initial_bomb_on_match_CROSS: bool
var initial_match_score_multipliers: Array[float]

var match_score_multipliers: Array[float] = [1.0, 1.0, 1.0, 1.0]
var bomb_on_match_4: bool = false
var bomb_on_match_5: bool = false
var bomb_on_match_L: bool = false
var bomb_on_match_T: bool = false
var bomb_on_match_CROSS: bool = false

@export var bonus_gem_chances: Array[float] = [
	0.0, # Rojo
	0.0, # Verde
	0.0, # Azul
	0.0  # Amarillo
]
@export var color_weights: Array[int] = [5, 5, 5, 5]
@export var multi_gem_chances: Array[float] = [
	0.0, # Rojo
	0.0, # Verde
	0.0, # Azul
	0.0  # Amarillo
]

signal turn_completed
signal resolution_completed(
	match_results: Array[MatchResult],
	consumed_special_type_gems: Array[Gem],
	explosion_affected_gems: Array[Gem],
	detected_shapes: Array[Dictionary],
	detonated_bombs: Array[Gem],
	chained_bomb_count: int,
	is_cascade: bool
)

func _ready() -> void:
	initial_color_weights = color_weights.duplicate()
	initial_bomb_on_match_4 = bomb_on_match_4
	initial_bomb_on_match_5 = bomb_on_match_5
	initial_bomb_on_match_L = bomb_on_match_L
	initial_bomb_on_match_T = bomb_on_match_T
	initial_bomb_on_match_CROSS = bomb_on_match_CROSS
	special_type_chances = {
		Gem.SpecialType.BONUS: bonus_gem_chances.duplicate(),
		Gem.SpecialType.MULTI: multi_gem_chances.duplicate()
	}

	initial_special_type_chances = special_type_chances.duplicate(true)
	var board_ready: bool = await reset_board()
	#_debug_set_bomb(3, 1)
	#_debug_set_bomb(3, 2)
	#_debug_set_bomb(3, 3)
	#_debug_set_multi(3, 1)
	#_debug_set_multi(3, 2)
	if not board_ready:
		push_error("No se pudo preparar un tablero inicial jugable")


func reset_board() -> bool:
	is_resolving = true
	
	_clear_board()
	
	for row in range(BOARD_SIZE):
		var row_data: Array = []
		board.append(row_data)

		for column in range(BOARD_SIZE):
			var gem = _create_gem(
				row,
				column,
				_get_valid_color_for(row, column)
			)
			row_data.append(gem)
	
	var board_ready: bool = await _ensure_board_has_moves()

	if not board_ready:
		push_error("No se pudo preparar un tablero jugable")
		return false
	
	assert(_is_board_state_consistent(),"Tablero inconsistente después de la inicialización")

	is_resolving = false
	return true


func reset_build() -> void:
	color_weights = initial_color_weights.duplicate()
	special_type_chances = initial_special_type_chances.duplicate(true)
	bomb_on_match_4 = initial_bomb_on_match_4
	bomb_on_match_5 = initial_bomb_on_match_5
	bomb_on_match_L = initial_bomb_on_match_L
	bomb_on_match_T = initial_bomb_on_match_T
	bomb_on_match_CROSS = initial_bomb_on_match_CROSS


func set_reverse_gravity(value: bool) -> void:
	reverse_gravity = value


func reset_encounter_modifiers() -> void:
	reverse_gravity = false
	bomb_required_triggers = 1
	bomb_trigger_counts.clear()


func _clear_board() -> void:
	for row in board:
		for gem in row:
			if is_instance_valid(gem):
				remove_child(gem)
				gem.queue_free()

	board.clear()
	selected_gem = null


func _get_valid_color_for(row: int, column: int) -> int:
	var available_colors: Array[int] = [0, 1, 2, 3]
	if column >= 2 and board[row][column - 1].color_id == board[row][column - 2].color_id:
		available_colors.erase(board[row][column - 1].color_id)
	if row >= 2 and board[row -1][column].color_id == board[row - 2][column].color_id:
		available_colors.erase(board[row -1][column].color_id)
	return _pick_weighted_color(available_colors)


func _get_random_color() -> int:
	var available_colors: Array[int] = [0, 1, 2, 3]
	return _pick_weighted_color(available_colors)


func _pick_weighted_color(available_colors: Array[int]) -> int:
	assert(not available_colors.is_empty(), "No hay colores disponibles para seleccionar")
	
	var probabilities: Array[float] = get_effective_color_probabilities()
	var total_available_probability: float = 0.0
	var accumulated_probability: float = 0.0
	
	for color_id in available_colors:
		assert(color_weights[color_id] > 0, "Los colores disponibles deben tener peso positivo")
		total_available_probability += probabilities[color_id]
	
	var roll: float = randf_range(0.0, total_available_probability)
	
	for color_id in available_colors:
		accumulated_probability += probabilities[color_id]
		
		if roll <= accumulated_probability:
			return color_id
	
	return available_colors.back()


func get_color_probability(color_id: int) -> float:
	assert(color_id >= 0 and color_id < color_weights.size(),"El color_id no corresponde a ningun color")
	
	var total_weight: int = 0
	
	for weight in color_weights:
		total_weight += weight
		
	assert(total_weight > 0, "El peso total de los colores debe ser mayor que cero")
	
	return float(color_weights[color_id]) / total_weight


func get_raw_color_probabilities() -> Array[float]:
	var total_weight: int = 0
	var probabilities: Array[float] = []
	
	for weight in color_weights:
		total_weight += weight
	assert(total_weight > 0, "El peso total de los colores debe ser mayor que cero")
	
	for weight in color_weights:
		probabilities.append(float(weight) / total_weight)
	
	return probabilities


func get_effective_color_probabilities() -> Array[float]:
	var probabilities := get_raw_color_probabilities()
	var capped_color_id : int = -1
	
	for color_id in range(probabilities.size()):
		if probabilities[color_id] > MAX_COLOR_PROBABILITY:
			capped_color_id = color_id
			break
	
	if capped_color_id == -1:
		return  probabilities
	
	var remaining_raw_probability: float = 0.0
	
	for color_id in range(probabilities.size()):
		if color_id != capped_color_id:
			remaining_raw_probability += probabilities[color_id]
	assert(remaining_raw_probability > 0, "La probabilidad restante debe ser mayor que cero")
	
	var available_probability: float = 1.0 - MAX_COLOR_PROBABILITY
	
	for color_id in range(probabilities.size()):
		if color_id == capped_color_id:
			probabilities[color_id] = MAX_COLOR_PROBABILITY
		else:
			probabilities[color_id] = probabilities[color_id] / remaining_raw_probability * available_probability
	
	return probabilities


func _is_board_state_consistent() -> bool:
	for row in range(BOARD_SIZE):
		for column in range (BOARD_SIZE):
			var gem = board[row][column]
			
			if gem == null:
				return false
			
			if gem.row != row or gem.column != column:
				return false
	return true

func set_input_enabled(enabled:bool) -> void:
	input_enabled = enabled

func _on_gem_clicked(gem) -> void:
	if is_resolving or not input_enabled:
		return
		
	if selected_gem == null:
		selected_gem = gem
		selected_gem.set_selected(true)
		
	elif selected_gem == gem:
		selected_gem.set_selected(false)
		selected_gem = null
		
	else:
		var first_gem = selected_gem
		selected_gem = null
		first_gem.set_selected(false)
		
		if _are_adjacent(first_gem, gem):
			is_resolving = true
			#print ("Intento de movimiento de (", first_gem.row, ", ", first_gem.column, ") por (", gem.row, ", ", gem.column, ") permitido")
				
			await _swap_gems(first_gem, gem)
			
			var matched_gems = _get_all_matched_gems(first_gem, gem)
			
			if matched_gems.is_empty():
				await _swap_gems(first_gem, gem)
				#print("Movimiento deshecho: no hay match")
			else:
				#print("Movimiento válido: hay ", matched_gems.size(), " gemas en match")
				await _resolve_matches(matched_gems)

				var board_ready: bool = await _ensure_board_has_moves()

				if not board_ready:
					push_error("El tablero ha quedado bloqueado y no se pudo recuperar")
					return
	
				assert(_is_board_state_consistent(),"Tablero inconsistente después de resolver una jugada")
				#print("Turno completado")
				turn_completed.emit()
			is_resolving = false
		#else:
			#print ("Intento de movimiento de (", first_gem.row, ", ", first_gem.column, ") por (", gem.row, ", ", gem.column, ") no permitido")
			
func _resolve_matches(matched_gems: Array, is_cascade: bool = false) -> void:
	var match_results: Array[MatchResult] = _get_match_results_on_board()
	
	var detected_shapes: Array[Dictionary] = match_detector.get_all_shapes(match_results)
	#for detected_shape in detected_shapes:
		#print(
			#match_detector.MatchShape.keys()[detected_shape["shape"]],
			#" color: ",
			#detected_shape["first_match"].color_id,
			#". Tamaño: ", match_detector.get_unique_gems_for_shape(detected_shape).size()
		#)
	
	var triggered_bombs: Array[Gem] = _get_triggered_bombs(matched_gems)
	
	var detonated_bombs: Array[Gem] = []

	var explosion_affected_gems: Array[Gem] = _process_bomb_explosions(triggered_bombs,matched_gems, detonated_bombs)
	
	var bomb_candidates: Array[Gem] = _get_bomb_candidates(match_results, detected_shapes)
	var armed_bomb_candidates: Array[Gem] = []

	for candidate in bomb_candidates:
		if explosion_affected_gems.has(candidate):
			armed_bomb_candidates.append(candidate)
	
	for candidate in armed_bomb_candidates:
		if not pending_bomb_detonations.has(candidate):
			pending_bomb_detonations.append(candidate)

	var consumed_special_type_gems: Array[Gem] = []

	for gem in matched_gems:
		if gem.special_type != Gem.SpecialType.NONE:
			if not consumed_special_type_gems.has(gem):
				consumed_special_type_gems.append(gem)

	for candidate in bomb_candidates:
		if candidate.special_type != Gem.SpecialType.NONE:
			if not consumed_special_type_gems.has(candidate):
				consumed_special_type_gems.append(candidate)

	for candidate in bomb_candidates:
		matched_gems.erase(candidate)
	
	#print("Gemas explotadas: ", explosion_affected_gems.size())
	#print("Gemas a eliminar: ", matched_gems.size())

	last_swapped_gem_a = null
	last_swapped_gem_b = null
	
	var chained_bomb_count: int = max(0,detonated_bombs.size() - triggered_bombs.size())
	
	print("BOMB detonadas: ", detonated_bombs.size())
	resolution_completed.emit(match_results, consumed_special_type_gems, explosion_affected_gems, detected_shapes, detonated_bombs, chained_bomb_count, is_cascade)
	
	#print("Resolviendo ", matched_gems.size(), " gemas")
	await _animate_and_remove_matches(matched_gems)
	
	for candidate in bomb_candidates:
		candidate.set_special_type(Gem.SpecialType.BOMB)
		
	var collapse_movements = _collapse_columns()
	await _animate_falling_gems(collapse_movements)

	var fill_movements = _fill_empty_spaces()
	await _animate_falling_gems(fill_movements)
	
	var cascade_matches = _get_all_matches_on_board()

	if not cascade_matches.is_empty():
		#print("Cascada encontrada: ", cascade_matches.size(), " gemas")
		await _resolve_matches(cascade_matches, true)
	else:
		if pending_bomb_detonations.is_empty():
			return
		
		var pending_bombs: Array[Gem] = pending_bomb_detonations.duplicate()
		var bombs_ready_to_detonate: Array[Gem] = []

		for bomb in pending_bombs:
			pending_bomb_detonations.erase(bomb)

			if _try_activate_bomb(bomb):
				bombs_ready_to_detonate.append(bomb)

		if bombs_ready_to_detonate.is_empty():
			return

		var gems_to_remove: Array[Gem] = []
		var pending_detonated_bombs: Array[Gem] = []

		explosion_affected_gems = _process_bomb_explosions(
			bombs_ready_to_detonate,
			gems_to_remove,
			pending_detonated_bombs
		)
		
		consumed_special_type_gems = []

		for gem in gems_to_remove:
			if gem.special_type != Gem.SpecialType.NONE:
				consumed_special_type_gems.append(gem)
		
		var no_match_results: Array[MatchResult] = []
		var no_detected_shapes: Array[Dictionary] = []
	
		chained_bomb_count = max(0,pending_detonated_bombs.size() - pending_bombs.size())
		
		print("BOMB detonadas: ", pending_detonated_bombs.size())
		resolution_completed.emit(no_match_results, consumed_special_type_gems, explosion_affected_gems, no_detected_shapes, pending_detonated_bombs, chained_bomb_count, is_cascade)
		
		#print("Detonando ", pending_bombs.size(), " bombas pendientes")
		#print("La detonación afecta a ", gems_to_remove.size(), " gemas")

		await _animate_and_remove_matches(gems_to_remove)

		collapse_movements = _collapse_columns()
		await _animate_falling_gems(collapse_movements)

		fill_movements = _fill_empty_spaces()
		await _animate_falling_gems(fill_movements)
		
		var new_cascade_matches = _get_all_matches_on_board()

		if not new_cascade_matches.is_empty():
			#print("Cascada encontrada tras detonación pendiente: ", new_cascade_matches.size(), " gemas")
			await _resolve_matches(new_cascade_matches, true)
		
func _collapse_columns() -> Array:
	var movements: Array = []
	
	for column in range(BOARD_SIZE):
		if reverse_gravity:
			var target_row = 0

			for row in range(BOARD_SIZE):
				var gem = board[row][column]

				if gem != null:
					if row != target_row:
						board[row][column] = null
						board[target_row][column] = gem
						gem.row = target_row

						movements.append({
							"gem": gem,
							"target_position": _get_position_for(target_row, column)
						})

					target_row += 1
		else:
			var target_row = BOARD_SIZE - 1

			for row in range(BOARD_SIZE - 1, -1, -1):
				var gem = board[row][column]

				if gem != null:
					if row != target_row:
						board[row][column] = null
						board[target_row][column] = gem
						gem.row = target_row
						movements.append({
							"gem": gem,
							"target_position": _get_position_for(target_row, column)
						})
					target_row -= 1
	return movements


func _animate_falling_gems(movements: Array) -> void:
	if movements.is_empty():
		return
	
	var tween = create_tween().set_parallel(true)

	for movement in movements:
		tween.tween_property(
			movement["gem"],
			"position",
			movement["target_position"],
			0.2
		)

	await tween.finished
		
func _are_adjacent(gem_a, gem_b) -> bool:
	return abs(gem_a.row - gem_b.row) \
		+ abs(gem_a.column - gem_b.column) == 1
		
func _get_position_for(row: int, column: int) -> Vector2:
	return BOARD_OFFSET + Vector2(
		column * TILE_SIZE,
		row * TILE_SIZE
	)
	
func _create_gem(row: int, column: int, color_id: int) -> Gem:
	var gem: Gem = GEM_SCENE.instantiate() as Gem

	gem.row = row
	gem.column = column
	gem.clicked.connect(_on_gem_clicked)

	add_child(gem)

	gem.set_color_id(color_id)
	gem.set_special_type(_roll_special_type(color_id))
	gem.position = _get_position_for(row, column)

	return gem


func _roll_special_type(color_id: int) -> Gem.SpecialType:
	var roll: float = randf()
	var accumulated_chance: float = 0.0

	for special_type in ROLLABLE_SPECIAL_TYPES:
		accumulated_chance += get_special_type_chance(
			special_type,
			color_id
		)

		if roll < accumulated_chance:
			return special_type

	return Gem.SpecialType.NONE


func _get_bomb_candidates(match_results: Array[MatchResult], detected_shapes: Array[Dictionary]) -> Array[Gem]:
	var candidates: Array[Gem] = []
	
	var shape_match_results: Array[MatchResult] = []

	for detected_shape in detected_shapes:
		var first_match: MatchResult = detected_shape["first_match"]
		var second_match: MatchResult = detected_shape["second_match"]

		if not shape_match_results.has(first_match):
			shape_match_results.append(first_match)

		if not shape_match_results.has(second_match):
			shape_match_results.append(second_match)

	for match_result in match_results:
		if shape_match_results.has(match_result):
			continue
			
		var creates_bomb: bool = (
			(match_result.length == 4 and bomb_on_match_4)
			or
			(match_result.length >= 5 and bomb_on_match_5)
		)
		if not creates_bomb:
			continue
		
		var candidate: Gem = null

		if (last_swapped_gem_a != null and match_result.gems.has(last_swapped_gem_a)):
			candidate = last_swapped_gem_a

		elif (last_swapped_gem_b != null and match_result.gems.has(last_swapped_gem_b)):
			candidate = last_swapped_gem_b
		
		else:
			candidate = match_result.gems[0]
		
		if candidate!= null and not candidates.has(candidate):
			candidates.append(candidate)
	
	for detected_shape in detected_shapes:
		var shape: MatchDetector.MatchShape = detected_shape["shape"]

		var creates_bomb: bool = (
			(shape == MatchDetector.MatchShape.L and bomb_on_match_L)
			or
			(shape == MatchDetector.MatchShape.T and bomb_on_match_T)
			or
			(shape == MatchDetector.MatchShape.CROSS and bomb_on_match_CROSS)
		)

		if not creates_bomb:
			continue
		
		var first_match: MatchResult = detected_shape["first_match"]
		var second_match: MatchResult = detected_shape["second_match"]

		var candidate: Gem = null

		for gem in first_match.gems:
			if second_match.gems.has(gem):
				candidate = gem
				break

		if candidate != null and not candidates.has(candidate):
			candidates.append(candidate)
	
	return candidates


func _get_triggered_bombs(matched_gems: Array) -> Array[Gem]:
	var triggered_bombs: Array[Gem] = []
	var bombs_to_preserve: Array[Gem] = []

	for gem in matched_gems:
		if gem.special_type != Gem.SpecialType.BOMB:
			continue

		if _try_activate_bomb(gem):
			triggered_bombs.append(gem)
		else:
			bombs_to_preserve.append(gem)

	for bomb in bombs_to_preserve:
		matched_gems.erase(bomb)

	return triggered_bombs


func set_bomb_required_triggers(value: int) -> void:
	assert(value >= 1, "Una bomba debe requerir al menos 1 activación")
	bomb_required_triggers = value


func _try_activate_bomb(bomb: Gem) -> bool:
	var trigger_count: int = int(bomb_trigger_counts.get(bomb, 0)) + 1

	if trigger_count >= bomb_required_triggers:
		bomb_trigger_counts.erase(bomb)
		return true

	bomb_trigger_counts[bomb] = trigger_count
	return false


func _get_bomb_explosion_gems(bomb: Gem) -> Array[Gem]:
	var explosion_gems: Array[Gem] = []

	for row_offset in range(-1, 2):
		for column_offset in range(-1, 2):
			var target_row = bomb.row + row_offset
			var target_column = bomb.column + column_offset
			
			if target_row < 0 or target_row >= BOARD_SIZE or target_column < 0 or target_column >= BOARD_SIZE:
				continue
			
			var gem: Gem = board[target_row][target_column]
			
			if gem != null:
				explosion_gems.append(gem)

	return explosion_gems


func _process_bomb_explosions(initial_bombs: Array[Gem],gems_to_remove: Array, detonated_bombs: Array[Gem]) -> Array[Gem]:
	
	var bombs_to_process: Array[Gem] = initial_bombs.duplicate()
	
	var explosion_affected_gems: Array[Gem] = []
	
	while not bombs_to_process.is_empty():
		var bomb: Gem = bombs_to_process.pop_front()
		
		if detonated_bombs.has(bomb):
			continue
		
		detonated_bombs.append(bomb)
		
		pending_bomb_detonations.erase(bomb)
		
		var explosion_gems: Array[Gem] = _get_bomb_explosion_gems(bomb)

		for gem in explosion_gems:
			if not explosion_affected_gems.has(gem):
				explosion_affected_gems.append(gem)
			
			if not gems_to_remove.has(gem):
				gems_to_remove.append(gem)
				
			if gem.special_type == Gem.SpecialType.BOMB:
				if not detonated_bombs.has(gem) and not bombs_to_process.has(gem):
					if _try_activate_bomb(gem):
						bombs_to_process.append(gem)
					else:
						gems_to_remove.erase(gem)
	
	return explosion_affected_gems


func get_special_type_chance(
	special_type: Gem.SpecialType,
	color_id: int
) -> float:
	assert(
		special_type_chances.has(special_type),
		"El SpecialType no tiene probabilidades configuradas"
	)

	var chances: Array = special_type_chances[special_type]

	assert(
		color_id >= 0 and color_id < chances.size(),
		"El color_id no tiene una probabilidad asociada"
	)

	var chance: float = chances[color_id]

	assert(
		chance >= 0.0 and chance <= 1.0,
		"La probabilidad debe estar entre 0.0 y 1.0"
	)

	return chance


func get_special_type_chances(
	special_type: Gem.SpecialType
) -> Array[float]:
	var chances: Array[float] = []

	for color_id in range(color_weights.size()):
		chances.append(
			get_special_type_chance(special_type, color_id)
		)

	return chances


func get_bonus_gem_chances() -> Array[float]:
	return get_special_type_chances(Gem.SpecialType.BONUS)


func get_multi_gem_chances() -> Array[float]:
	return get_special_type_chances(Gem.SpecialType.MULTI)


func _remove_gem(gem) -> void:
	bomb_trigger_counts.erase(gem)
	var row = gem.row
	var column = gem.column
	board[row][column] = null
	gem.queue_free()

func _animate_and_remove_matches(matched_gems: Array) -> void:
	var tween = create_tween().set_parallel(true)

	for matched_gem in matched_gems:
		tween.tween_property(
			matched_gem,
			"scale",
			Vector2.ZERO,
			0.2
		)

	await tween.finished

	for matched_gem in matched_gems:
		_remove_gem(matched_gem)
		
func _swap_gems(gem_a, gem_b) -> void:
	_swap_gems_in_board(gem_a, gem_b)
	
	var target_position_a = _get_position_for(gem_a.row, gem_a.column)
	var target_position_b = _get_position_for(gem_b.row, gem_b.column)
	
	var tween = create_tween().set_parallel(true)

	tween.tween_property(
		gem_a,
		"position",
		target_position_a,
		0.15
	)
	tween.tween_property(
		gem_b,
		"position",
		target_position_b,
		0.15
	)
	
	await tween.finished
	
func _swap_gems_in_board(gem_a, gem_b) -> void:
	last_swapped_gem_a = gem_a
	last_swapped_gem_b = gem_b
	var old_row_a = gem_a.row
	var old_column_a = gem_a.column
	var old_row_b = gem_b.row
	var old_column_b = gem_b.column

	board[old_row_a][old_column_a] = gem_b
	board[old_row_b][old_column_b] = gem_a
	
	gem_a.row = old_row_b
	gem_a.column = old_column_b
	gem_b.row = old_row_a
	gem_b.column = old_column_a
	
func _swap_creates_match(gem_a, gem_b) -> bool:
	_swap_gems_in_board(gem_a, gem_b)
	var has_matches: bool = !_get_all_matched_gems(gem_a, gem_b).is_empty()
	_swap_gems_in_board(gem_a, gem_b)
	return has_matches
	
func _has_possible_moves() -> bool:
	for row in range(BOARD_SIZE):
		for column in range(BOARD_SIZE -1):
			if _swap_creates_match(board[row][column], board[row][column +1]):
				return true
	for row in range(BOARD_SIZE -1):
		for column in range(BOARD_SIZE):
			if _swap_creates_match(board[row][column], board[row +1][column]):
				return true
	return false
	
func _shuffle_board_once() -> void:
	var shuffled_gems: Array = []
	
	for row in range(BOARD_SIZE):
		for column in range(BOARD_SIZE):
			shuffled_gems.append(board[row][column])
	
	shuffled_gems.shuffle()
	
	var gem_index: int = 0
	
	for row in range(BOARD_SIZE):
		for column in range(BOARD_SIZE):
			var gem = shuffled_gems[gem_index]
			board[row][column] = gem
			gem.row = row
			gem.column = column
			gem_index += 1
		
func _try_reshuffle_board(max_attempts: int) -> bool:
	var initial_gems: Array = []
	for row in range(BOARD_SIZE):
		for column in range(BOARD_SIZE):
			initial_gems.append(board[row][column])
			
	for attempt in range(max_attempts):
		_shuffle_board_once()
		if _is_board_playable():
			return true
	
	var gem_index = 0
	for row in range(BOARD_SIZE):
		for column in range(BOARD_SIZE):
			var gem = initial_gems[gem_index]
			board[row][column]= gem
			gem.row = row
			gem.column = column
			gem_index += 1
	return false
	
func _reshuffle_deadlocked_board() -> bool:
	var reshuffle_succeeded: bool = _try_reshuffle_board(100)

	if not reshuffle_succeeded:
		return false

	await _animate_gems_to_board_positions()
	return true

func _animate_gems_to_board_positions() -> void:
	var tween = create_tween().set_parallel(true)

	for row in range(BOARD_SIZE):
		for column in range(BOARD_SIZE):
			var gem = board[row][column]
			var target_position = _get_position_for(row, column)

			tween.tween_property(
				gem,
				"position",
				target_position,
				1
			)
	
	await tween.finished
			
func _is_board_playable() -> bool:
	if _get_match_results_on_board():
		return false
	elif !_has_possible_moves():
		return false
	else:
		return true
		
func _ensure_board_has_moves() -> bool:
	if _has_possible_moves():
		return true

	return await _reshuffle_deadlocked_board()

func _fill_empty_spaces() -> Array:
	var movements: Array = []

	for column in range(BOARD_SIZE):
		var empty_count := 0

		for row in range(BOARD_SIZE):
			if board[row][column] == null:
				var gem = _create_gem(row, column, _get_random_color())
				board[row][column] = gem

				var target_position = _get_position_for(row, column)

				if reverse_gravity:
					gem.position = _get_position_for(
						BOARD_SIZE + empty_count,
						column
					)
				else:
					gem.position = _get_position_for(
						-1 - empty_count,
						column
					)

				movements.append({
					"gem": gem,
					"target_position": target_position
				})

				empty_count += 1

	return movements


func _get_match_results_on_board() -> Array[MatchResult]:
	return match_detector.get_match_results(board)


func _get_unique_gems_from_results(match_results: Array[MatchResult]) -> Array:
	return match_detector.get_unique_gems(match_results)


func _get_all_matched_gems(gem_a, gem_b) -> Array:
	return match_detector.get_matches_for_swap(board, gem_a, gem_b)


func _get_all_matches_on_board() -> Array:

	return _get_unique_gems_from_results(_get_match_results_on_board())


func add_color_weight(color_id: int, amount: int) -> void:
	assert(
		color_id >= 0 and color_id < color_weights.size(),
		"El color_id no corresponde a ningún color"
	)
	assert(amount > 0, "El aumento de peso debe ser positivo")

	color_weights[color_id] += amount


func add_special_type_chance(
	special_type: Gem.SpecialType,
	color_id: int,
	amount: float
) -> void:
	assert(amount > 0.0)

	var chances: Array = special_type_chances[special_type]

	assert(
		color_id >= 0 and color_id < chances.size()
	)

	var total_chance: float = (
		_get_total_special_type_chance_for_color(color_id)
	)

	assert(
		total_chance + amount <= 1.0
	)

	chances[color_id] += amount


func _get_total_special_type_chance_for_color(
	color_id: int
) -> float:
	var total_chance: float = 0.0

	for special_type in ROLLABLE_SPECIAL_TYPES:
		total_chance += get_special_type_chance(
			special_type,
			color_id
		)

	return total_chance


func add_bonus_gem_chance(color_id: int, amount: float) -> void:
	add_special_type_chance(
		Gem.SpecialType.BONUS,
		color_id,
		amount
	)


func add_multi_gem_chance(color_id: int, amount: float) -> void:
	add_special_type_chance(
		Gem.SpecialType.MULTI,
		color_id,
		amount
	)


func enable_bomb_on_match_4() -> void:	
	bomb_on_match_4 = true


func disable_bomb_on_match_4() -> void:
	bomb_on_match_4 = false


func enable_bomb_on_match_5() -> void:
	bomb_on_match_5 = true


func disable_bomb_on_match_5() -> void:
	bomb_on_match_5 = false


func enable_bomb_on_match_L() -> void:	
	bomb_on_match_L = true


func disable_bomb_on_match_L() -> void:
	bomb_on_match_L = false


func enable_bomb_on_match_T() -> void:	
	bomb_on_match_T = true


func disable_bomb_on_match_T() -> void:
	bomb_on_match_T = false


func enable_bomb_on_match_CROSS() -> void:	
	bomb_on_match_CROSS = true


func disable_bomb_on_match_CROSS() -> void:
	bomb_on_match_CROSS = false


func _debug_test_weighted_picker() -> void:
	var available_colors: Array[int] = [0, 1, 2, 3]
	var results: Array[int] = [0, 0, 0, 0]
	var attempts: int = 6000
	for _attempt in range(attempts):
		var color_id = _pick_weighted_color(available_colors)
		results[color_id] += 1
	print(results)


func _debug_set_bomb(row: int, column: int) -> void:
	var gem: Gem = board[row][column]

	if gem == null:
		return

	gem.set_special_type(Gem.SpecialType.BOMB)


func _debug_set_multi(row: int, column: int) -> void:
	var gem: Gem = board[row][column]

	if gem == null:
		return

	gem.set_special_type(Gem.SpecialType.MULTI)
