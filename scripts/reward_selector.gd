class_name RewardSelector
extends RefCounted

const RARITY_WEIGHTS: Dictionary = {
	RewardRarity.Type.COMMON: 70,
	RewardRarity.Type.UNCOMMON: 25,
	RewardRarity.Type.RARE: 5
}


func generate_options(
	reward_pool: Array[RewardDefinition],
	run_state: RunState,
	option_count: int = 3
) -> Array[RewardDefinition]:
	var available_rewards: Array[RewardDefinition] = []

	for reward in reward_pool:
		if _is_reward_available(reward, run_state):
			available_rewards.append(reward)

	var options: Array[RewardDefinition] = []

	while options.size() < option_count and not available_rewards.is_empty():
		var selected_reward: RewardDefinition = _select_reward(
			available_rewards
		)

		if selected_reward == null:
			break

		options.append(selected_reward)

		available_rewards.erase(selected_reward)

	return options


func generate_milestone_options(
	reward_pool: Array[RewardDefinition],
	run_state: RunState,
	option_count: int = 2
) -> Array[RewardDefinition]:
	var available_rewards: Array[RewardDefinition] = []

	for reward in reward_pool:
		if _is_reward_available(reward, run_state):
			available_rewards.append(reward)

	var options: Array[RewardDefinition] = []

	while options.size() < option_count and not available_rewards.is_empty():
		var selected_reward: RewardDefinition = available_rewards.pick_random()

		options.append(selected_reward)
		available_rewards.erase(selected_reward)

	return options


func _select_reward(
	available_rewards: Array[RewardDefinition]
) -> RewardDefinition:
	var rarity: int = _select_rarity(available_rewards)

	var rewards_of_rarity: Array[RewardDefinition] = []

	for reward in available_rewards:
		if reward.rarity == rarity:
			rewards_of_rarity.append(reward)

	if rewards_of_rarity.is_empty():
		return null

	var family: String = _select_family(rewards_of_rarity)

	var rewards_of_family: Array[RewardDefinition] = []

	for reward in rewards_of_rarity:
		if reward.family == family:
			rewards_of_family.append(reward)

	if rewards_of_family.is_empty():
		return null

	return rewards_of_family.pick_random()


func _select_rarity(
	available_rewards: Array[RewardDefinition]
) -> int:
	var available_rarity_weights: Dictionary = {}

	for reward in available_rewards:
		if not available_rarity_weights.has(reward.rarity):
			available_rarity_weights[reward.rarity] = RARITY_WEIGHTS.get(
				reward.rarity,
				0
			)

	return int(_pick_weighted_key(available_rarity_weights))


func _select_family(
	rewards: Array[RewardDefinition]
) -> String:
	var family_weights: Dictionary = {}

	for reward in rewards:
		if family_weights.has(reward.family):
			assert(
				family_weights[reward.family] == reward.family_weight,
				"Variantes de la misma familia tienen pesos distintos: "
				+ reward.family
			)
		else:
			family_weights[reward.family] = reward.family_weight

	return String(_pick_weighted_key(family_weights))


func _pick_weighted_key(weights: Dictionary) -> Variant:
	var total_weight: float = 0.0

	for weight in weights.values():
		total_weight += float(weight)

	assert(total_weight > 0.0)

	var roll: float = randf() * total_weight
	var accumulated_weight: float = 0.0

	for key in weights:
		accumulated_weight += float(weights[key])

		if roll < accumulated_weight:
			return key

	# Protección ante posibles errores de precisión decimal.
	return weights.keys().back()


func _is_reward_available(
	reward: RewardDefinition,
	run_state: RunState
) -> bool:
	if reward.max_acquisitions >= 0:
		var acquired_count: int = run_state.get_reward_count(reward.id)

		if acquired_count >= reward.max_acquisitions:
			return false

	for requirement in reward.requirements:
		if not _meets_requirement(requirement, run_state):
			return false

	return true


func _meets_requirement(
	requirement: Dictionary,
	run_state: RunState
) -> bool:
	var requirement_type: int = requirement["type"]

	match requirement_type:
		RewardRequirementType.Type.HAS_REWARD:
			return run_state.has_reward(
				requirement["reward_id"]
			)

		RewardRequirementType.Type.MATCH_DISCOVERED:
			return run_state.is_match_type_discovered(
				requirement["match_type"]
			)

		_:
			push_error(
				"Tipo de requisito no soportado: ",
				requirement_type
			)
			return false


func debug_simulate_selections(
	reward_pool: Array[RewardDefinition],
	run_state: RunState,
	iterations: int = 10000
) -> void:
	var rarity_counts: Dictionary = {}
	var family_counts: Dictionary = {}
	var reward_counts: Dictionary = {}

	for i in range(iterations):
		var options: Array[RewardDefinition] = generate_options(
			reward_pool,
			run_state,
			1
		)

		if options.is_empty():
			continue

		var reward: RewardDefinition = options[0]

		rarity_counts[reward.rarity] = rarity_counts.get(
			reward.rarity,
			0
		) + 1

		family_counts[reward.family] = family_counts.get(
			reward.family,
			0
		) + 1

		reward_counts[reward.id] = reward_counts.get(
			reward.id,
			0
		) + 1

	print("=== RAREZAS ===")
	for rarity in rarity_counts:
		print(
			RewardRarity.Type.keys()[rarity],
			": ",
			rarity_counts[rarity]
		)

	print("=== FAMILIAS ===")
	for family in family_counts:
		print(family, ": ", family_counts[family])

	print("=== REWARDS ===")
	for reward_id in reward_counts:
		print(reward_id, ": ", reward_counts[reward_id])
