class_name BossDefinition
extends Resource


enum BossEffectType {
	CASCADE_SCORE_MULTIPLIER,
	REVERSE_GRAVITY,
	BOMB_REQUIRED_TRIGGERS
}


var id: String
var title: String
var description: String
var effects: Array[Dictionary] = []


func _init(
	p_id: String = "",
	p_title: String = "",
	p_description: String = "",
	p_effects: Array[Dictionary] = []
) -> void:
	id = p_id
	title = p_title
	description = p_description
	effects = p_effects
