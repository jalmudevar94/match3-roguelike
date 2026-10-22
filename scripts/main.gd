extends Node2D

const SPECIAL_TARGET_MULTIPLIER: float = 1.0

@export var starting_target_score: int = 300
@export var target_score_increase: int = 10
@export var starting_moves: int = 5
@export var encounters_per_run: int = 21

@onready var board: Board = $Board
@onready var hud = $HUD
@onready var score_manager = $ScoreManager

var run_state: RunState = RunState.new()
var reward_selector: RewardSelector = RewardSelector.new()

var base_starting_moves: int
var moves_remaining: int
var is_finished: bool = false
var is_restarting: bool = false
var current_score: int = 0
var current_encounter: int = 1
var current_target_score: int
var current_reward_options: Array[RewardDefinition] = []
var current_encounter_type: EncounterType = EncounterType.NORMAL
var last_encounter_end: EncounterEnd = EncounterEnd.RUN_DEFEAT
var pending_modifier_reward: RewardDefinition = null
var reward_pool: Array[RewardDefinition] = []
var milestone_reward_pool: Array[RewardDefinition] = []

var available_bosses: Array[BossDefinition] = []
var block_boss: BossDefinition = null

enum EncounterType {
	NORMAL,
	SPECIAL
}

enum EncounterEnd {
	ENCOUNTER_VICTORY,
	RUN_DEFEAT,
	RUN_VICTORY
}


func _ready() -> void:
	base_starting_moves = starting_moves
	
	_load_reward_resources("res://rewards")
	_validate_reward_pool()
	
	print("=== NORMAL REWARD POOL ===")
	for reward in reward_pool:
		print(
			reward.id,
			" | family: ", reward.family,
			" | source: ", reward.source
		)

	print("=== MILESTONE REWARD POOL ===")
	for reward in milestone_reward_pool:
		print(
			reward.id,
			" | family: ", reward.family,
			" | source: ", reward.source
		)
	
	#reward_selector.debug_simulate_selections(
		#reward_pool,
		#run_state,
		#10000
	#)
	
	_reset_boss_pool()
	_select_new_block_boss()
	_start_encounter()


func _load_reward_resources(path: String) -> void:
	var dir := DirAccess.open(path)

	if dir == null:
		push_error("No se pudo abrir la carpeta de rewards: " + path)
		return

	dir.list_dir_begin()

	var file_name := dir.get_next()

	while file_name != "":
		if dir.current_is_dir():
			if not file_name.begins_with("."):
				_load_reward_resources(path.path_join(file_name))

		elif file_name.get_extension() == "tres":
			var reward := load(path.path_join(file_name)) as RewardDefinition

			if reward == null:
				push_error(
					"El resource no es RewardDefinition: "
					+ path.path_join(file_name)
				)
			else:
				_add_reward_to_pool(reward)

		file_name = dir.get_next()

	dir.list_dir_end()


func _add_reward_to_pool(reward: RewardDefinition) -> void:
	match reward.source:
		RewardSource.Type.NORMAL:
			reward_pool.append(reward)

		RewardSource.Type.MILESTONE:
			milestone_reward_pool.append(reward)

		_:
			push_error(
				"Reward con source desconocido: " + reward.id
			)


func _validate_reward_pool() -> void:
	var seen_ids: Dictionary = {}

	for reward in reward_pool + milestone_reward_pool:
		assert(
			not seen_ids.has(reward.id),
			"Reward duplicada en pool: " + reward.id
		)

		seen_ids[reward.id] = true

	print("Rewards cargadas correctamente: ", seen_ids.size())


func _start_encounter() -> void:
	_reset_encounter_modifiers()

	current_encounter_type = _calculate_encounter_type()

	if current_encounter_type == EncounterType.SPECIAL:
		if block_boss != null:
			_apply_boss(block_boss)
	
	current_score = 0
	current_target_score = _calculate_target_score()
	moves_remaining = starting_moves
	is_finished = false
	
	hud.set_moves_remaining(moves_remaining)
	hud.set_score(current_score, current_target_score)
	hud.set_color_probabilities(board.get_effective_color_probabilities())
	hud.set_bonus_gem_chances(board.get_bonus_gem_chances())
	hud.set_multi_gem_chances(board.get_multi_gem_chances())
	hud.set_scoring_levels(score_manager.get_scoring_levels())
	hud.set_encounter(current_encounter, current_encounter_type == EncounterType.SPECIAL)
	if block_boss != null:
		hud.set_block_boss(
			block_boss.title,
			block_boss.description,
			current_encounter_type == EncounterType.SPECIAL
		)
	for i in range(run_state.modifier_slots.size()):
		var modifier: ModifierInstance = run_state.modifier_slots[i]

		if modifier == null:
			print(i, ": vacío")
		else:
			print(
				i,
				": ",
				modifier.modifier_id,
				" | rewards: ",
				modifier.reward_counts
			)


func _reset_encounter_modifiers() -> void:
	score_manager.reset_encounter_modifiers()
	board.reset_encounter_modifiers()


func _on_board_turn_completed() -> void:
	if is_finished:
		return
		
	moves_remaining = maxi(moves_remaining - 1, 0)
	print("Movimientos restantes: ", moves_remaining)
	hud.set_moves_remaining(moves_remaining)
	
	_check_encounter_end()
	

func _check_encounter_end() -> void:
	if current_score >= current_target_score:
		_finish_encounter(true)
	elif moves_remaining == 0:
		_finish_encounter(false)


func _finish_encounter(victory:bool) -> void:
	is_finished = true
	board.set_input_enabled(false)
	current_reward_options.clear()
	
	if not victory:
		last_encounter_end = EncounterEnd.RUN_DEFEAT
		hud.show_encounter_defeat()
		return
	
	if _is_final_encounter():
		last_encounter_end = EncounterEnd.RUN_VICTORY
		hud.show_run_completed()
		return
	
	last_encounter_end = EncounterEnd.ENCOUNTER_VICTORY
	current_reward_options = _generate_post_encounter_reward_options()
	hud.set_reward_options(current_reward_options)
	hud.show_encounter_victory()


func _is_final_encounter() -> bool:
	return current_encounter >= encounters_per_run


func _calculate_target_score() -> int:
	var target = starting_target_score + ((current_encounter - 1) * target_score_increase)
	
	if current_encounter_type == EncounterType.SPECIAL:
		target = int(round(target * SPECIAL_TARGET_MULTIPLIER))
	return target


func _calculate_encounter_type() -> EncounterType:
	if current_encounter % 3 == 0:
		return EncounterType.SPECIAL

	return EncounterType.NORMAL


func _reset_boss_pool() -> void:
	available_bosses = BossCatalog.get_all_bosses()


func _select_new_block_boss() -> void:
	if available_bosses.is_empty():
		_reset_boss_pool()

	if available_bosses.is_empty():
		block_boss = null
		return

	block_boss = available_bosses.pick_random()
	available_bosses.erase(block_boss)


func _apply_boss(boss: BossDefinition) -> void:
	for effect in boss.effects:
		_apply_boss_effect(effect)


func _apply_boss_effect(effect: Dictionary) -> void:
	match effect.type:
		BossDefinition.BossEffectType.CASCADE_SCORE_MULTIPLIER:
			score_manager.set_encounter_cascade_score_multiplier(
				float(effect["value"])
			)
		
		BossDefinition.BossEffectType.REVERSE_GRAVITY:
			board.set_reverse_gravity(true)
		
		BossDefinition.BossEffectType.BOMB_REQUIRED_TRIGGERS:
			board.set_bomb_required_triggers(
				int(effect["value"])
			)

		_:
			push_error(
				"Tipo de efecto de boss desconocido: "
				+ str(effect.type)
			)


func _on_score_manager_score_changed(new_score: int) -> void:
	
	current_score = new_score
	#print("Puntuación: ", current_score, " / ", current_target_score)
	hud.set_score(current_score, current_target_score)


func _on_score_manager_score_event_created(event: Dictionary) -> void:
	print(
		[event["type"]],
		" x", event["count"],
		" → +", event["score"]
	)


func _on_hud_restart_requested() -> void:
	await _continue_after_encounter()


func _continue_after_encounter() -> void:
	if is_restarting:
		return
	
	is_restarting = true
	board.set_input_enabled(false)
	
	match last_encounter_end:
		EncounterEnd.ENCOUNTER_VICTORY:
			current_encounter += 1

			if _is_first_encounter_of_block():
				_select_new_block_boss()

		EncounterEnd.RUN_DEFEAT, EncounterEnd.RUN_VICTORY:
			current_encounter = 1
			board.reset_build()
			score_manager.reset_build()
			run_state.reset()
			
			starting_moves = base_starting_moves
			
			_reset_boss_pool()
			_select_new_block_boss()
	
	var board_ready: bool = await board.reset_board()
	if not board_ready:
		is_restarting = false
		return
	
	score_manager.reset_score()
	_start_encounter()
	hud.hide_result()
	
	board.set_input_enabled(true)
	is_restarting = false


func _is_first_encounter_of_block() -> bool:
	return (current_encounter - 1) % 3 == 0


func _generate_reward_options() -> Array[RewardDefinition]:
	return reward_selector.generate_options(
		reward_pool,
		run_state,
		3
	)


func _generate_post_encounter_reward_options() -> Array[RewardDefinition]:
	if current_encounter_type == EncounterType.SPECIAL:
		return reward_selector.generate_options(
			milestone_reward_pool,
			run_state,
			2
		)

	return _generate_reward_options()


func _on_hud_reward_selected(option_index: int) -> void:
	if is_restarting or last_encounter_end != EncounterEnd.ENCOUNTER_VICTORY:
		return

	if pending_modifier_reward != null:
		assert(
			option_index >= 0
			and option_index < run_state.modifier_slots.size(),
			"El índice de slot no es válido"
		)

		var reward_to_add: RewardDefinition = pending_modifier_reward

		_remove_modifier(option_index)

		var added: bool = _try_add_modifier_reward(reward_to_add)
		assert(added, "Debería haber un slot libre después del reemplazo")

		_apply_reward(reward_to_add)
		_record_reward_acquired(reward_to_add)

		await _finish_reward_selection()
		return

	assert(
		option_index >= 0
		and option_index < current_reward_options.size(),
		"El índice de recompensa no es válido"
	)

	var reward: RewardDefinition = current_reward_options[option_index]

	if reward.occupies_slot:
		if not _try_add_modifier_reward(reward):
			pending_modifier_reward = reward
			hud.show_modifier_replacement_options(
				run_state.modifier_slots
			)
			return

	_apply_reward(reward)
	_record_reward_acquired(reward)

	await _finish_reward_selection()


func _try_add_modifier_reward(reward: RewardDefinition) -> bool:
	var existing_modifier: ModifierInstance = run_state.get_modifier(
		reward.modifier_id
	)

	if existing_modifier != null:
		existing_modifier.add_reward(reward)
		return true

	var slot_index: int = run_state.add_modifier(
		ModifierInstance.new(reward)
	)

	return slot_index != -1


func _apply_reward_effect(effect: RewardEffectDefinition) -> void:
	var reward_type: RewardEffectType.Type = effect.type

	match reward_type:
		RewardEffectType.Type.ADD_COLOR_WEIGHT:
			board.add_color_weight(
				effect.color_id,
				int(effect.amount)
			)

		RewardEffectType.Type.ADD_BONUS_CHANCE:
			board.add_bonus_gem_chance(
				effect.color_id,
				float(effect.amount)
			)
		
		RewardEffectType.Type.ADD_BONUS_GEM_POINTS_BONUS:
			score_manager.add_bonus_gem_points_bonus(
				int(effect.amount)
			)

		RewardEffectType.Type.ADD_MULTI_CHANCE:
			board.add_multi_gem_chance(
				effect.color_id,
				float(effect.amount)
			)
		
		RewardEffectType.Type.ADD_MULTI_GEM_MULTIPLIER_BONUS:
			score_manager.add_multi_gem_multiplier_bonus(
				float(effect.amount)
			)
		
		RewardEffectType.Type.ENABLE_BOMB_MATCH_4:
			board.enable_bomb_on_match_4()
		
		RewardEffectType.Type.ENABLE_BOMB_MATCH_5:
			board.enable_bomb_on_match_5()
		
		RewardEffectType.Type.ENABLE_BOMB_MATCH_L:
			board.enable_bomb_on_match_L()
		
		RewardEffectType.Type.ENABLE_BOMB_MATCH_T:
			board.enable_bomb_on_match_T()
		
		RewardEffectType.Type.ENABLE_BOMB_MATCH_CROSS:
			board.enable_bomb_on_match_CROSS()
		
		RewardEffectType.Type.ADD_MATCH_SCORE_MULTIPLIER:
			score_manager.add_match_score_multiplier(
				effect.color_id,
				float(effect.amount)
			)
		
		RewardEffectType.Type.ADD_MATCH_4_MULTIPLIER_GROWTH:
			score_manager.add_match_4_multiplier_growth(
				effect.color_id,
				float(effect.amount)
			)
		
		RewardEffectType.Type.ADD_L_SHAPE_SCORE_GROWTH:
			score_manager.add_l_shape_score_growth(
				int(effect.amount)
			)
		
		RewardEffectType.Type.ADD_T_SHAPE_SCORE_GROWTH:
			score_manager.add_t_shape_score_growth(
				int(effect.amount)
			)
		
		RewardEffectType.Type.ADD_CROSS_SHAPE_SCORE_GROWTH:
			score_manager.add_cross_shape_score_growth(
				int(effect.amount)
			)
		
		RewardEffectType.Type.ADD_BOMB_CHAIN_MULTIPLIER_GROWTH:
			score_manager.add_bomb_chain_multiplier(
				float(effect.amount)
			)
		
		RewardEffectType.Type.ADD_CASCADE_MATCH_SCORE_BONUS:
			score_manager.add_cascade_match_score_bonus(
				int(effect.amount)
			)
		
		RewardEffectType.Type.ADD_CASCADE_MATCH_SCORE_MULTIPLIER:
			score_manager.add_cascade_match_score_multiplier(
				float(effect.amount)
			)
		
		RewardEffectType.Type.ADD_CASCADE_SPECIAL_TYPE_SCORE_BONUS:
			score_manager.add_cascade_special_type_score_bonus(
				int(effect.amount)
			)
		
		RewardEffectType.Type.ADD_SCORING_LEVEL:
			score_manager.add_scoring_level(
				effect.scoring_source,
				int(effect.amount)
			)
		
		RewardEffectType.Type.ADD_SCORING_LEVEL_GROWTH:
			score_manager.add_scoring_level_growth(
				effect.scoring_source,
				int(effect.amount)
			)
		
		RewardEffectType.Type.ADD_STARTING_MOVES:
			starting_moves += int(effect.amount)
	
		_:
		
			push_error("Tipo de recompensa desconocido")


func _remove_reward_effect(effect: RewardEffectDefinition) -> void:
	var reward_type: RewardEffectType.Type = effect.type

	match reward_type:
		RewardEffectType.Type.ENABLE_BOMB_MATCH_4:
			board.disable_bomb_on_match_4()
		
		RewardEffectType.Type.ENABLE_BOMB_MATCH_5:
			board.disable_bomb_on_match_5()
		
		RewardEffectType.Type.ENABLE_BOMB_MATCH_L:
			board.disable_bomb_on_match_L()
		
		RewardEffectType.Type.ENABLE_BOMB_MATCH_T:
			board.disable_bomb_on_match_T()
		
		RewardEffectType.Type.ENABLE_BOMB_MATCH_CROSS:
			board.disable_bomb_on_match_CROSS()
		
		RewardEffectType.Type.ADD_MATCH_4_MULTIPLIER_GROWTH:
			score_manager.remove_match_4_multiplier_growth(
				effect.color_id,
				float(effect.amount)
			)
		
		RewardEffectType.Type.ADD_L_SHAPE_SCORE_GROWTH:
			score_manager.remove_l_shape_score_growth(
				int(effect.amount)
			)
		
		RewardEffectType.Type.ADD_T_SHAPE_SCORE_GROWTH:
			score_manager.remove_t_shape_score_growth(
				int(effect.amount)
			)
		
		RewardEffectType.Type.ADD_CROSS_SHAPE_SCORE_GROWTH:
			score_manager.remove_cross_shape_score_growth(
				int(effect.amount)
			)
		
		RewardEffectType.Type.ADD_BOMB_CHAIN_MULTIPLIER_GROWTH:
			score_manager.remove_bomb_chain_multiplier(
				float(effect.amount)
			)
		
		RewardEffectType.Type.ADD_CASCADE_MATCH_SCORE_BONUS:
			score_manager.remove_cascade_match_score_bonus(
				int(effect.amount)
			)
		
		RewardEffectType.Type.ADD_CASCADE_MATCH_SCORE_MULTIPLIER:
			score_manager.remove_cascade_match_score_multiplier(
				float(effect.amount)
			)
		
		RewardEffectType.Type.ADD_CASCADE_SPECIAL_TYPE_SCORE_BONUS:
			score_manager.remove_cascade_special_type_score_bonus(
				int(effect.amount)
			)
		
		RewardEffectType.Type.ADD_BONUS_GEM_POINTS_BONUS:
			score_manager.remove_bonus_gem_points_bonus(
				int(effect.amount)
			)
		
		RewardEffectType.Type.ADD_MULTI_GEM_MULTIPLIER_BONUS:
			score_manager.remove_multi_gem_multiplier_bonus(
				float(effect.amount)
			)
		
		RewardEffectType.Type.ADD_SCORING_LEVEL_GROWTH:
			score_manager.remove_scoring_level_growth(
				effect.scoring_source,
				int(effect.amount)
			)
	
		_:
		
			push_error("Eliminación de efecto no implementada para: " + str(reward_type))


func _apply_reward(reward: RewardDefinition) -> void:

	for effect in reward.effects:
		_apply_reward_effect(effect)
	
	
	#_record_reward_acquired(reward)


func _remove_reward(reward: RewardDefinition) -> void:
	for effect in reward.effects:
		_remove_reward_effect(effect)


func _remove_modifier(slot_index: int) -> void:
	var modifier: ModifierInstance = run_state.remove_modifier(slot_index)

	if modifier == null:
		return
	
	if modifier.modifier_id == "bomb_points_stacker":
		var charges: int = int(
			modifier.state.get("charges", 0)
		)

		if charges > 0:
			score_manager.remove_bomb_gem_points_bonus(charges)
			modifier.state["charges"] = 0

	if modifier.modifier_id == "matchL_score_engine":
		var accumulated_growth: int = int(
			modifier.state.get("accumulated_growth", 0)
		)

		if accumulated_growth > 0:
			score_manager.remove_l_shape_score_bonus(accumulated_growth)
			modifier.state["accumulated_growth"] = 0

	if modifier.modifier_id == "matchT_score_engine":
		var accumulated_growth: int = int(
			modifier.state.get("accumulated_growth", 0)
		)

		if accumulated_growth > 0:
			score_manager.remove_t_shape_score_bonus(accumulated_growth)
			modifier.state["accumulated_growth"] = 0

	if modifier.modifier_id == "matchCROSS_score_engine":
		var accumulated_growth: int = int(
			modifier.state.get("accumulated_growth", 0)
		)

		if accumulated_growth > 0:
			score_manager.remove_cross_shape_score_bonus(accumulated_growth)
			modifier.state["accumulated_growth"] = 0
			
	if modifier.modifier_id == "bonus_gem_score_engine":
		var charges: int = int(
			modifier.state.get("charges", 0)
		)

		if charges > 0:
			score_manager.remove_bonus_gem_points_bonus(charges)
			modifier.state["charges"] = 0

	for reward_id in modifier.reward_counts:
		var reward: RewardDefinition = _get_reward_definition(reward_id)

		if reward == null:
			push_error("No se encontró la reward: " + reward_id)
			continue
		
		var accumulated_growth: float = modifier.state.get(
			"accumulated_growth",
			0.0
		)
		
		if accumulated_growth > 0.0:
			for effect in reward.effects:
				if effect.type == RewardEffectType.Type.ADD_MATCH_4_MULTIPLIER_GROWTH:
					score_manager.remove_match_score_multiplier(
						effect.color_id,
						accumulated_growth
					)

					modifier.state["accumulated_growth"] = 0.0
					break
		
		var reward_count: int = int(modifier.reward_counts.get(reward_id, 0))
		for i in range(reward_count):
			_remove_reward(reward)


func _get_reward_definition(reward_id: String) -> RewardDefinition:
	for reward in reward_pool:
		if reward.id == reward_id:
			return reward

	return null


func _record_reward_acquired(reward: RewardDefinition) -> void:
	run_state.record_reward(reward.id)


func _on_hud_reward_passed() -> void:
	if is_restarting or last_encounter_end != EncounterEnd.ENCOUNTER_VICTORY:
		return

	await _finish_reward_selection()


func _finish_reward_selection() -> void:
	pending_modifier_reward = null
	current_reward_options.clear()

	await _continue_after_encounter()


func _on_board_resolution_for_discovery(
	match_results: Array[MatchResult],
	_consumed_special_type_gems: Array,
	_explosion_affected_gems: Array[Gem],
	detected_shapes: Array[Dictionary],
	_detonated_bombs: Array[Gem],
	_chained_bomb_count: int,
	_is_cascade: bool
) -> void:
	for match_result in match_results:
		if match_result.length == 3:
			run_state.discover_match_type(MatchType.Type.MATCH_3)
		elif match_result.length == 4:
			run_state.discover_match_type(MatchType.Type.MATCH_4)
		elif match_result.length >= 5:
			run_state.discover_match_type(MatchType.Type.MATCH_5_PLUS)

	for detected_shape in detected_shapes:
		match detected_shape["shape"]:
			MatchDetector.MatchShape.L:
				run_state.discover_match_type(MatchType.Type.L)

			MatchDetector.MatchShape.T:
				run_state.discover_match_type(MatchType.Type.T)

			MatchDetector.MatchShape.CROSS:
				run_state.discover_match_type(MatchType.Type.CROSS)


func _on_score_manager_match_4_multiplier_grown(color_id: int, amount: float) -> void:
	for modifier in run_state.modifier_slots:
		if modifier == null:
			continue

		for reward_id in modifier.reward_counts:
			var reward: RewardDefinition = _get_reward_definition(reward_id)

			if reward == null:
				continue

			for effect in reward.effects:
				if (
					effect.type == RewardEffectType.Type.ADD_MATCH_4_MULTIPLIER_GROWTH
					and effect.color_id == color_id
				):
					var accumulated_growth: float = modifier.state.get(
						"accumulated_growth",
						0.0
					)

					modifier.state["accumulated_growth"] = (
						accumulated_growth + amount
					)

					print(
						"Growth acumulado del modificador ",
						modifier.modifier_id,
						": ",
						modifier.state["accumulated_growth"]
					)

					return


#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_cancel"):
		#_remove_modifier(0)


func _on_score_manager_bombs_scored(detonated_bomb_count: int) -> void:
	var modifier: ModifierInstance = run_state.get_modifier(
		"bomb_points_stacker"
	)

	if modifier == null:
		return

	var current_charges: int = int(
		modifier.state.get("charges", 0)
	)

	var gained_charges: int = detonated_bomb_count

	modifier.state["charges"] = current_charges + gained_charges

	score_manager.add_bomb_gem_points_bonus(gained_charges)

	#print(
		#"Pólvora | cargas: ",
		#modifier.state["charges"],
		#" | bonus BOMB: ",
		#score_manager.bomb_gem_points_bonus
	#)


func _on_score_manager_l_shape_score_grown(amount: int) -> void:
	var modifier: ModifierInstance = run_state.get_modifier(
		"matchL_score_engine"
	)

	if modifier == null:
		return

	var accumulated_growth: int = int(
		modifier.state.get("accumulated_growth", 0)
	)

	modifier.state["accumulated_growth"] = (
		accumulated_growth + amount
	)


func _on_score_manager_t_shape_score_grown(amount: int) -> void:
	var modifier: ModifierInstance = run_state.get_modifier(
		"matchT_score_engine"
	)

	if modifier == null:
		return

	var accumulated_growth: int = int(
		modifier.state.get("accumulated_growth", 0)
	)

	modifier.state["accumulated_growth"] = (
		accumulated_growth + amount
	)


func _on_score_manager_cross_shape_score_grown(amount: int) -> void:
	var modifier: ModifierInstance = run_state.get_modifier(
		"matchCROSS_score_engine"
	)

	if modifier == null:
		return

	var accumulated_growth: int = int(
		modifier.state.get("accumulated_growth", 0)
	)

	modifier.state["accumulated_growth"] = (
		accumulated_growth + amount
	)


func _on_score_manager_bonus_gems_scored(count: int) -> void:
	var modifier: ModifierInstance = run_state.get_modifier(
		"bonus_gem_score_engine"
	)

	if modifier == null:
		return

	var current_charges: int = int(
		modifier.state.get("charges", 0)
	)

	var gained_charges: int = count

	modifier.state["charges"] = current_charges + gained_charges

	score_manager.add_bonus_gem_points_bonus(gained_charges)

	#print(
		#"BONUS | cargas: ",
		#modifier.state["charges"],
		#" | BONUS extra: ",
		#score_manager.bonus_gem_points_bonus
	#)


func _on_score_manager_scoring_level_changed(_source: int, _new_level: int) -> void:
	hud.set_scoring_levels(score_manager.get_scoring_levels())
