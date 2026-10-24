class_name RunState
extends RefCounted


const MODIFIER_SLOT_COUNT: int = 4

var acquired_reward_counts: Dictionary = {}
var discovered_match_types: Array[int] = []
var modifier_slots: Array[ModifierInstance] = []
var coins: int = 0


func _init() -> void:
	modifier_slots.resize(MODIFIER_SLOT_COUNT)


func get_free_modifier_slot() -> int:
	for i in range(modifier_slots.size()):
		if modifier_slots[i] == null:
			return i

	return -1


func add_modifier(modifier: ModifierInstance) -> int:
	var free_slot: int = get_free_modifier_slot()

	if free_slot == -1:
		return -1

	modifier_slots[free_slot] = modifier
	return free_slot


func get_modifier(modifier_id: String) -> ModifierInstance:
	for modifier in modifier_slots:
		if modifier != null and modifier.modifier_id == modifier_id:
			return modifier

	return null


func remove_modifier(slot_index: int) -> ModifierInstance:
	var modifier: ModifierInstance = modifier_slots[slot_index]

	if modifier == null:
		return null

	for reward_id in modifier.reward_counts:
		var reward_count: int = modifier.reward_counts[reward_id]
		remove_reward_count(reward_id, reward_count)

	modifier_slots[slot_index] = null
	return modifier


func discover_match_type(match_type: MatchType.Type) -> void:
	if not discovered_match_types.has(match_type):
		discovered_match_types.append(match_type)
		print("Match descubierto: ", MatchType.Type.keys()[match_type])


func is_match_type_discovered(match_type: MatchType.Type) -> bool:
	return discovered_match_types.has(match_type)


func record_reward(reward_id: String) -> void:
	var current_count: int = acquired_reward_counts.get(reward_id, 0)
	acquired_reward_counts[reward_id] = current_count + 1


func remove_reward_count(reward_id: String, amount: int = 1) -> void:
	var current_count: int = get_reward_count(reward_id)
	var new_count: int = current_count - amount

	if new_count <= 0:
		acquired_reward_counts.erase(reward_id)
	else:
		acquired_reward_counts[reward_id] = new_count


func get_reward_count(reward_id: String) -> int:
	return acquired_reward_counts.get(reward_id, 0)


func has_reward(reward_id: String) -> bool:
	return get_reward_count(reward_id) > 0


func reset() -> void:
	acquired_reward_counts.clear()
	discovered_match_types.clear()
	modifier_slots.clear()
	modifier_slots.resize(MODIFIER_SLOT_COUNT)
	coins = 0


func add_coins(amount: int) -> void:
	coins += amount


func spend_coins(amount: int) -> bool:
	if amount > coins:
		return false

	coins -= amount
	return true
