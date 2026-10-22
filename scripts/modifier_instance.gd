class_name ModifierInstance
extends RefCounted


var modifier_id: String
var reward_counts: Dictionary = {}
var state: Dictionary = {}


func _init(modifier_definition: RewardDefinition) -> void:
	modifier_id = modifier_definition.modifier_id
	add_reward(modifier_definition)


func add_reward(reward: RewardDefinition) -> void:
	assert(reward.modifier_id == modifier_id)

	var count: int = reward_counts.get(reward.id, 0)
	reward_counts[reward.id] = count + 1
