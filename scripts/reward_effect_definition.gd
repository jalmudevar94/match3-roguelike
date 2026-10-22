class_name RewardEffectDefinition
extends Resource

const ScoreManagerScript = preload("res://scripts/score_manager.gd")


@export var type: RewardEffectType.Type
@export var amount: float = 0.0
@export var color_id: int = -1
@export var scoring_source: ScoreManagerScript.ScoringSource
