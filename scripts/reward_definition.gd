class_name RewardDefinition
extends Resource


@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""

@export var effects: Array[RewardEffectDefinition] = []
@export var requirements: Array[Dictionary] = []

@export var max_acquisitions: int = -1

@export var family: String = ""
@export var rarity: RewardRarity.Type = RewardRarity.Type.COMMON
@export var family_weight: int = 100

@export var occupies_slot: bool = false
@export var modifier_id: String = ""

@export var source: RewardSource.Type = RewardSource.Type.NORMAL


func _init(
	reward_id: String = "",
	reward_title: String = "",
	reward_description: String = "",
	reward_effects: Array[RewardEffectDefinition] = [],
	reward_requirements: Array[Dictionary] = [],
	reward_max_acquisitions: int = -1,
	reward_family: String = "",
	reward_rarity: RewardRarity.Type = RewardRarity.Type.COMMON,
	reward_family_weight: int = 100,
	reward_occupies_slot: bool = false,
	reward_modifier_id: String = "",
	reward_source: RewardSource.Type = RewardSource.Type.NORMAL
) -> void:
	id = reward_id
	title = reward_title
	description = reward_description
	effects = reward_effects
	requirements = reward_requirements
	max_acquisitions = reward_max_acquisitions
	family = reward_family
	rarity = reward_rarity
	family_weight = reward_family_weight
	occupies_slot = reward_occupies_slot
	modifier_id = reward_modifier_id
	source = reward_source
