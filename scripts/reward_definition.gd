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


#static func from_dictionary(data: Dictionary) -> RewardDefinition:
	#var reward_effects: Array[RewardEffectDefinition] = []
#
	#for effect_data in data.get("effects", []):
		#assert(effect_data.has("type"))
		#var effect := RewardEffectDefinition.new()
#
		#effect.type = effect_data["type"]
#
		#effect.amount = float(
			#effect_data.get("amount", 0.0)
		#)
#
		#effect.color_id = int(
			#effect_data.get("color_id", -1)
		#)
#
		#if effect_data.has("scoring_source"):
			#effect.scoring_source = effect_data["scoring_source"]
#
		#reward_effects.append(effect)
		#
	#var reward_requirements: Array[Dictionary] = []
#
	#for requirement in data.get("requirements", []):
		#reward_requirements.append(requirement)
		#
	#assert(data.has("family"))
	#assert(not String(data["family"]).is_empty())
	#assert(data.has("rarity"))
	#assert(data.has("family_weight"))
	#assert(int(data["family_weight"]) > 0)
	#if data.get("occupies_slot", false):
		#assert(
			#not String(data.get("modifier_id", "")).is_empty(),
			#"Reward con slot sin modifier_id: " + String(data["id"])
		#)
#
	#return RewardDefinition.new(
		#data.get("id", ""),
		#data.get("title", ""),
		#data.get("description", ""),
		#reward_effects,
		#reward_requirements,
		#data.get("max_stacks", -1),
		#data.get("family", ""),
		#data.get("rarity", RewardRarity.Type.COMMON),
		#data.get("family_weight", 100),
		#data.get("occupies_slot", false),
		#data.get("modifier_id", ""),
		#data.get("source", RewardSource.Type.NORMAL)
	#)
