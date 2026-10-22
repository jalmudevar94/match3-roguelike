extends Node

const BONUS_GEM_POINTS: int = 20
#const BOMB_GEM_POINTS: int = 10
const MULTI_GEM_BASE_MULTIPLIER: float = 2.0
const SCORING_SOURCE_CONFIG: Dictionary = {
	ScoringSource.MATCH_3: {
		"base_score": 30,
		"growth_per_level": 5
	},
	ScoringSource.MATCH_4: {
		"base_score": 50,
		"growth_per_level": 10
	},
	ScoringSource.MATCH_5_PLUS: {
		"base_score": 100,
		"growth_per_level": 20,
		"base_gem_count": 5,
		"extra_gem_score": 20
	},
	ScoringSource.L_SHAPE: {
		"base_score": 100,
		"growth_per_level": 20,
		"base_gem_count": 5,
		"extra_gem_score": 20
	},
	ScoringSource.T_SHAPE: {
		"base_score": 100,
		"growth_per_level": 20,
		"base_gem_count": 5,
		"extra_gem_score": 20
	},
	ScoringSource.CROSS_SHAPE: {
		"base_score": 100,
		"growth_per_level": 20,
		"base_gem_count": 5,
		"extra_gem_score": 20
	},
	ScoringSource.BOMB: {
		"base_score": 10,
		"growth_per_level": 2
	}
}

var score: int = 0
var match_score_multipliers: Array[float] = [1.0, 1.0, 1.0, 1.0]
var match_4_multiplier_growth: Array[float] = [0.0, 0.0, 0.0, 0.0]
var l_shape_score_growth: int = 0
var l_shape_score_bonus: int = 0
var t_shape_score_growth: int = 0
var t_shape_score_bonus: int = 0
var cross_shape_score_growth: int = 0
var cross_shape_score_bonus: int = 0
var bomb_gem_points_bonus: int = 0
var bomb_chain_multiplier_growth: float = 0
var cascade_match_score_bonus: int = 0
var cascade_match_score_multiplier: float = 1.0
var cascade_special_type_score_bonus: int = 0
var bonus_gem_points_bonus: int = 0
var multi_gem_multiplier_bonus: float = 0.0
var scoring_levels: Dictionary = {
	ScoringSource.MATCH_3: 1,
	ScoringSource.MATCH_4: 1,
	ScoringSource.MATCH_5_PLUS: 1,
	ScoringSource.L_SHAPE: 1,
	ScoringSource.T_SHAPE: 1,
	ScoringSource.CROSS_SHAPE: 1,
	ScoringSource.BOMB: 1
}
var scoring_level_growth: Dictionary = {
	ScoringSource.MATCH_3: 0,
	ScoringSource.MATCH_4: 0,
	ScoringSource.MATCH_5_PLUS: 0,
	ScoringSource.L_SHAPE: 0,
	ScoringSource.T_SHAPE: 0,
	ScoringSource.CROSS_SHAPE: 0,
	ScoringSource.BOMB: 0
}

var encounter_cascade_score_multiplier: float = 1.0

enum ScoreEventType {
	MATCH,
	L_SHAPE,
	T_SHAPE,
	CROSS_SHAPE,
	BOMB,
	BONUS,
	CASCADE_SPECIAL_TYPE
}

enum ScoringSource {
	MATCH_3,
	MATCH_4,
	MATCH_5_PLUS,
	L_SHAPE,
	T_SHAPE,
	CROSS_SHAPE,
	BOMB
}

signal score_changed(new_score: int)
signal score_event_created(event: Dictionary)
signal match_4_multiplier_grown(color_id: int, amount: float)
signal bombs_scored(detonated_bomb_count: int)
signal l_shape_score_grown(amount: int)
signal t_shape_score_grown(amount: int)
signal cross_shape_score_grown(amount: int)
signal bonus_gems_scored(count: int)
signal scoring_level_changed(source: ScoringSource, new_level:int)


func _get_score_for_match(match_result: MatchResult) -> int:
	var base_score: int = 0

	match match_result.length:
		3:
			base_score = get_level_adjusted_base_score(
				ScoringSource.MATCH_3
			)

		4:
			base_score = get_level_adjusted_base_score(
				ScoringSource.MATCH_4
			)

		_:
			if match_result.length >= 5:
				base_score = get_scoring_source_base_score(
					ScoringSource.MATCH_5_PLUS,
					match_result.length
				)

	return int(base_score * match_score_multipliers[match_result.color_id])


func reset_score() -> void:
	score = 0
	score_changed.emit(score)


func _on_board_resolution_completed(
		match_results: Array[MatchResult],
		consumed_special_type_gems: Array,
		explosion_affected_gems: Array[Gem],
		detected_shapes: Array[Dictionary],
		detonated_bombs: Array[Gem],
		chained_bomb_count: int,
		is_cascade: bool
	) -> void:
#	MATCHES POINTS
	var match_score: int = 0
	var normal_match_score: int = 0
	var normal_match_count: int = 0
	var matches_in_shapes: Array[MatchResult] = []
	var shape_events: Array[Dictionary] = []
	var l_count: int = 0
	var t_count: int = 0
	var cross_count: int = 0
	var current_cascade_multiplier: float = 1.0
	var current_cascade_bonus: int = 0
	
	var cascade_special_type_score: int = 0
	var cascade_special_type_count: int = 0
	
	var pending_scoring_level_growth: Dictionary = {}

	if is_cascade:
		current_cascade_multiplier = cascade_match_score_multiplier * encounter_cascade_score_multiplier
		current_cascade_bonus = cascade_match_score_bonus

		cascade_special_type_count = consumed_special_type_gems.size()

		cascade_special_type_score = (
			cascade_special_type_count
			* cascade_special_type_score_bonus
		)
	
	for detected_shape in detected_shapes:
		var first_match: MatchResult = detected_shape["first_match"]
		var second_match: MatchResult = detected_shape["second_match"]
		
		if not matches_in_shapes.has(first_match):
			matches_in_shapes.append(first_match)
		
		if not matches_in_shapes.has(second_match):
			matches_in_shapes.append(second_match)
		
		var color_id: int = first_match.color_id
		var shape: MatchDetector.MatchShape = detected_shape["shape"]
		
		var shape_gems: Array[Gem] = _get_unique_gems_from_matches(first_match,second_match)

		var scoring_source: ScoringSource
		var shape_score_bonus: int = 0
		
		match shape:
			MatchDetector.MatchShape.L:
				scoring_source = ScoringSource.L_SHAPE
				shape_score_bonus = l_shape_score_bonus
				l_count += 1
				_accumulate_scoring_level_growth(
					pending_scoring_level_growth,
					scoring_source
				)

			MatchDetector.MatchShape.T:
				scoring_source = ScoringSource.T_SHAPE
				shape_score_bonus = t_shape_score_bonus
				t_count += 1
				_accumulate_scoring_level_growth(
					pending_scoring_level_growth,
					scoring_source
				)

			MatchDetector.MatchShape.CROSS:
				scoring_source = ScoringSource.CROSS_SHAPE
				shape_score_bonus = cross_shape_score_bonus
				cross_count += 1
				_accumulate_scoring_level_growth(
					pending_scoring_level_growth,
					scoring_source
				)

		var shape_base_score: int = (
			get_scoring_source_base_score(
				scoring_source,
				shape_gems.size()
			)
			+ shape_score_bonus
		)

		var multi_multiplier: float = _get_multi_multiplier_for_gems(shape_gems)

		var shape_score: int = roundi(
			shape_base_score
			* match_score_multipliers[color_id]
			* multi_multiplier
			* current_cascade_multiplier
		)

		shape_score += current_cascade_bonus
		
		match_score += shape_score
		
		var event_type: int
		
		match shape:
			MatchDetector.MatchShape.L:
				event_type = ScoreEventType.L_SHAPE

			MatchDetector.MatchShape.T:
				event_type = ScoreEventType.T_SHAPE

			MatchDetector.MatchShape.CROSS:
				event_type = ScoreEventType.CROSS_SHAPE

		shape_events.append({
			"type": event_type,
			"count": 1,
			"score": shape_score
		})
	
	var l_growth: int = l_count * l_shape_score_growth
	var t_growth: int = t_count * t_shape_score_growth
	var cross_growth: int = cross_count * cross_shape_score_growth

	if l_growth > 0:
		l_shape_score_bonus += l_growth
		l_shape_score_grown.emit(l_growth)

	if t_growth > 0:
		t_shape_score_bonus += t_growth
		t_shape_score_grown.emit(t_growth)

	if cross_growth > 0:
		cross_shape_score_bonus += cross_growth
		cross_shape_score_grown.emit(cross_growth)
	
	for match_result in match_results:
		if matches_in_shapes.has(match_result):
			continue

		var current_match_score: int = _get_score_for_match(match_result)
		
		var multi_multiplier: float = _get_multi_multiplier_for_gems(match_result.gems)

		current_match_score = roundi(
			current_match_score
			* multi_multiplier
			* current_cascade_multiplier
		)

		current_match_score += current_cascade_bonus

		match_score += current_match_score
		normal_match_score += current_match_score
		normal_match_count += 1

		var scoring_source: ScoringSource = (
			_get_scoring_source_for_match_length(
				match_result.length
			)
		)

		_accumulate_scoring_level_growth(
			pending_scoring_level_growth,
			scoring_source
		)

	for match_result in match_results:
		if match_result.length != 4:
			continue

		var growth_amount: float = match_4_multiplier_growth[
			match_result.color_id
		]

		add_match_score_multiplier(
			match_result.color_id,
			growth_amount
		)

		if growth_amount > 0.0:
			match_4_multiplier_grown.emit(
				match_result.color_id,
				growth_amount
			)
	
#	BONUS POINTS
	var bonus_score: int = 0
	var unique_gems: Array[Gem] = explosion_affected_gems.duplicate()
	var bonus_gem_count: int = 0
	
	for match_result in match_results:
		for gem in match_result.gems:
			if not unique_gems.has(gem):
				unique_gems.append(gem)

	for gem in unique_gems:
		if gem.special_type == Gem.SpecialType.BONUS:
			bonus_gem_count += 1
	
	bonus_score = bonus_gem_count * (BONUS_GEM_POINTS + bonus_gem_points_bonus)
	
	if bonus_gem_count > 0:
		bonus_gems_scored.emit(bonus_gem_count)
	
#	EXPLOSION POINTS
	var bomb_chain_multiplier: float = (
		1 + chained_bomb_count * bomb_chain_multiplier_growth
	)

	var bomb_score_before_chain: float = 0.0
	var bomb_gem_points: int = (
		get_level_adjusted_base_score(
			ScoringSource.BOMB
		)
		+ bomb_gem_points_bonus
	)

	for gem in explosion_affected_gems:
		var current_gem_score: float = bomb_gem_points

		if gem.special_type == Gem.SpecialType.MULTI:
			current_gem_score *= _get_multi_gem_multiplier()

		bomb_score_before_chain += current_gem_score

	var bomb_score: int = roundi(
		bomb_score_before_chain * bomb_chain_multiplier
	)
	
	_accumulate_scoring_level_growth(
		pending_scoring_level_growth,
		ScoringSource.BOMB,
		detonated_bombs.size()
	)
	
	if not detonated_bombs.is_empty():
		bombs_scored.emit(detonated_bombs.size())
	
	var resolution_score: int = match_score + bonus_score + bomb_score + cascade_special_type_score
	score += resolution_score
	score_changed.emit(score)
	
	for source in pending_scoring_level_growth:
		add_scoring_level(
			source,
			pending_scoring_level_growth[source]
		)
	
	var score_events: Array[Dictionary] = []
	
	if normal_match_count > 0:
		var match_event: Dictionary = {
			"type": ScoreEventType.MATCH,
			"count": normal_match_count,
			"score": normal_match_score
		}
		score_events.append(match_event)
	
	for shape_event in shape_events:
		score_events.append(shape_event)
	
	if explosion_affected_gems.size() > 0:
		var bomb_event: Dictionary = {
			"type": ScoreEventType.BOMB,
			"count": explosion_affected_gems.size(),
			"score": bomb_score
			}
		score_events.append(bomb_event)
	
	if bonus_gem_count > 0:
		var bonus_event: Dictionary = {
			"type": ScoreEventType.BONUS,
			"count": bonus_gem_count,
			"score": bonus_score
			}
		score_events.append(bonus_event)
	
	if cascade_special_type_count > 0 and cascade_special_type_score > 0:
		var cascade_special_type_event: Dictionary = {
			"type": ScoreEventType.CASCADE_SPECIAL_TYPE,
			"count": cascade_special_type_count,
			"score": cascade_special_type_score
		}
		score_events.append(cascade_special_type_event)
	
	for event in score_events:
		score_event_created.emit(event)


func _get_multi_gem_multiplier() -> float:
	return (
		MULTI_GEM_BASE_MULTIPLIER
		+ multi_gem_multiplier_bonus
	)


func _get_multi_multiplier_for_gems(gems: Array) -> float:
	var multi_gem_count: int = 0

	for gem in gems:
		if gem.special_type == Gem.SpecialType.MULTI:
			multi_gem_count += 1

	return pow(
		_get_multi_gem_multiplier(),
		multi_gem_count
	)


func _get_unique_gems_from_matches(
	first_match: MatchResult,
	second_match: MatchResult
) -> Array[Gem]:
	var unique_gems: Array[Gem] = []

	for gem in first_match.gems:
		if not unique_gems.has(gem):
			unique_gems.append(gem)

	for gem in second_match.gems:
		if not unique_gems.has(gem):
			unique_gems.append(gem)

	return unique_gems


func reset_build() -> void:
	reset_scoring_levels()
	reset_scoring_level_growth()
	
	match_score_multipliers = [1.0, 1.0, 1.0, 1.0]
	match_4_multiplier_growth = [0.0, 0.0, 0.0, 0.0]
	
	l_shape_score_growth = 0
	l_shape_score_bonus = 0
	t_shape_score_growth = 0
	t_shape_score_bonus = 0
	cross_shape_score_growth = 0
	cross_shape_score_bonus = 0
	
	bomb_gem_points_bonus = 0
	bomb_chain_multiplier_growth = 0
	
	cascade_match_score_bonus = 0
	cascade_match_score_multiplier = 1.0
	cascade_special_type_score_bonus = 0
	
	bonus_gem_points_bonus = 0
	
	multi_gem_multiplier_bonus = 0.0


func set_encounter_cascade_score_multiplier(value: float) -> void:
	encounter_cascade_score_multiplier = value


func reset_encounter_modifiers() -> void:
	encounter_cascade_score_multiplier = 1.0


func get_scoring_level(source: ScoringSource) -> int:
	assert(
		scoring_levels.has(source),
		"La fuente de scoring no tiene nivel"
	)

	return scoring_levels[source]


func get_scoring_levels() -> Dictionary:
	return scoring_levels.duplicate()


func add_scoring_level(
	source: ScoringSource,
	amount: int
) -> void:
	assert(
		scoring_levels.has(source),
		"La fuente de scoring no tiene nivel"
	)
	assert(
		amount >= 0,
		"No se puede añadir una cantidad negativa de niveles"
	)

	scoring_levels[source] += amount

	scoring_level_changed.emit(source, scoring_levels[source])


func reset_scoring_levels() -> void:
	for source in scoring_levels:
		scoring_levels[source] = 1


func reset_scoring_level_growth() -> void:
	for source in scoring_level_growth:
		scoring_level_growth[source] = 0


func _accumulate_scoring_level_growth(
	pending_growth: Dictionary,
	source: ScoringSource,
	event_count: int = 1
) -> void:
	var growth_per_event: int = scoring_level_growth[source]

	if growth_per_event <= 0:
		return

	if event_count <= 0:
		return

	var growth_amount: int = (
		growth_per_event
		* event_count
	)

	pending_growth[source] = (
		int(pending_growth.get(source, 0))
		+ growth_amount
	)


func _get_scoring_source_for_match_length(
	match_length: int
) -> ScoringSource:
	assert(match_length >= 3)

	match match_length:
		3:
			return ScoringSource.MATCH_3

		4:
			return ScoringSource.MATCH_4

		_:
			return ScoringSource.MATCH_5_PLUS


func get_level_adjusted_base_score(
	source: ScoringSource
) -> int:
	assert(
		SCORING_SOURCE_CONFIG.has(source),
		"La fuente de scoring no tiene configuración de nivel"
	)

	var config: Dictionary = SCORING_SOURCE_CONFIG[source]
	var level: int = get_scoring_level(source)

	var base_score: int = config["base_score"]
	var growth_per_level: int = config["growth_per_level"]

	return (
		base_score
		+ (level - 1) * growth_per_level
	)


func get_scoring_source_base_score(
	source: ScoringSource,
	gem_count: int
) -> int:
	var base_score: int = get_level_adjusted_base_score(source)
	var config: Dictionary = SCORING_SOURCE_CONFIG[source]

	if (
		config.has("base_gem_count")
		and config.has("extra_gem_score")
	):
		var base_gem_count: int = config["base_gem_count"]
		var extra_gem_score: int = config["extra_gem_score"]

		var extra_gem_count: int = max(
			0,
			gem_count - base_gem_count
		)

		base_score += extra_gem_count * extra_gem_score

	return base_score


func add_match_score_multiplier(color_id: int, amount: float) -> void:
	assert(
		color_id >= 0 and color_id < match_score_multipliers.size(),
		"El color_id no corresponde a ningún color"
	)

	match_score_multipliers[color_id] += amount


func remove_match_score_multiplier(color_id: int, amount: float) -> void:
	assert(
		color_id >= 0 and color_id < match_score_multipliers.size(),
		"El color_id no corresponde a ningún color"
	)

	match_score_multipliers[color_id] -= amount


func add_match_4_multiplier_growth(color_id: int, amount: float) -> void:
	assert(
		color_id >= 0 and color_id < match_4_multiplier_growth.size(),
		"El color_id no corresponde a ningún color"
	)

	match_4_multiplier_growth[color_id] += amount


func remove_match_4_multiplier_growth(color_id: int, amount: float) -> void:
	assert(
		color_id >= 0 and color_id < match_4_multiplier_growth.size(),
		"El color_id no corresponde a ningún color"
	)

	match_4_multiplier_growth[color_id] -= amount


func add_l_shape_score_growth(amount: int) -> void:
	l_shape_score_growth += amount


func remove_l_shape_score_growth(amount: int) -> void:
	l_shape_score_growth -= amount


func remove_l_shape_score_bonus(amount: int) -> void:
	l_shape_score_bonus -= amount


func add_t_shape_score_growth(amount: int) -> void:
	t_shape_score_growth += amount


func remove_t_shape_score_growth(amount: int) -> void:
	t_shape_score_growth -= amount


func remove_t_shape_score_bonus(amount: int) -> void:
	t_shape_score_bonus -= amount


func add_cross_shape_score_growth(amount: int) -> void:
	cross_shape_score_growth += amount


func remove_cross_shape_score_growth(amount: int) -> void:
	cross_shape_score_growth -= amount


func remove_cross_shape_score_bonus(amount: int) -> void:
	cross_shape_score_bonus -= amount


func add_bomb_gem_points_bonus(amount: int) -> void:
	bomb_gem_points_bonus += amount


func remove_bomb_gem_points_bonus(amount: int) -> void:
	bomb_gem_points_bonus -= amount


func add_bomb_chain_multiplier(amount: float) -> void:
	bomb_chain_multiplier_growth += amount


func remove_bomb_chain_multiplier(amount: float) -> void:
	bomb_chain_multiplier_growth -= amount


func add_cascade_match_score_bonus(amount: int) -> void:
	cascade_match_score_bonus += amount


func remove_cascade_match_score_bonus(amount: int) -> void:
	cascade_match_score_bonus -= amount


func add_cascade_match_score_multiplier(amount: float) -> void:
	cascade_match_score_multiplier += amount


func remove_cascade_match_score_multiplier(amount: float) -> void:
	cascade_match_score_multiplier -= amount


func add_cascade_special_type_score_bonus(amount: int) -> void:
	cascade_special_type_score_bonus += amount


func remove_cascade_special_type_score_bonus(amount: int) -> void:
	cascade_special_type_score_bonus -= amount


func add_bonus_gem_points_bonus(amount: int) -> void:
	bonus_gem_points_bonus += amount


func remove_bonus_gem_points_bonus(amount: int) -> void:
	bonus_gem_points_bonus -= amount


func add_multi_gem_multiplier_bonus(amount: float) -> void:
	multi_gem_multiplier_bonus += amount


func remove_multi_gem_multiplier_bonus(amount: float) -> void:
	multi_gem_multiplier_bonus -= amount


func add_scoring_level_growth(source: ScoringSource,amount: int) -> void:
	assert(scoring_level_growth.has(source))
	assert(amount >= 0)

	scoring_level_growth[source] += amount


func remove_scoring_level_growth(source: ScoringSource,amount: int) -> void:
	assert(scoring_level_growth.has(source))
	assert(amount >= 0)
	assert(
		scoring_level_growth[source] >= amount,
		"scoring_level_growth no puede ser negativo"
	)

	scoring_level_growth[source] -= amount
