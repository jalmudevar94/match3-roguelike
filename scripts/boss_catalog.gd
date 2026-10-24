class_name BossCatalog
extends RefCounted


static func get_all_bosses() -> Array[BossDefinition]:
	return [
		BossDefinition.new(
			"weak_cascades",
			"Cascadas debilitadas",
			"Los matches de cascadas puntúan la mitad.",
			[
				{
					"type": BossDefinition.BossEffectType.CASCADE_SCORE_MULTIPLIER,
					"value": 0.5
				}
			]
		),

		BossDefinition.new(
			"reverse_gravity",
			"notweN",
			"Las gemas caen hacia arriba.",
			[
				{
					"type": BossDefinition.BossEffectType.REVERSE_GRAVITY
				}
			]
		),

		BossDefinition.new(
			"reinforced_bombs",
			"Bombas reforzadas",
			"Las bombas detonan tras dos activaciones.",
			[
				{
					"type": BossDefinition.BossEffectType.BOMB_REQUIRED_TRIGGERS,
					"value": 2
				}
			]
		)
	]
