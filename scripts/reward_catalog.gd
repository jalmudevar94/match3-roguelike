#class_name RewardCatalog
#extends RefCounted
#
#const ScoreManagerScript = preload("res://scripts/score_manager.gd")
#
#
#static func get_reward_data() -> Array[Dictionary]:
	#return [
		#{
			#"id": "color_weight_red",
			#"title": "Más rojo",
			#"description": "+2 peso rojo",
			#"family": "color_weight",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 80,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_COLOR_WEIGHT,
					#"color_id": 0,
					#"amount": 2
				#}
			#]
		#},
		#{
			#"id": "color_weight_green",
			#"title": "Más verde",
			#"description": "+2 peso verde",
			#"family": "color_weight",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 80,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_COLOR_WEIGHT,
					#"color_id": 1,
					#"amount": 2
				#}
			#]
		#},
		#{
			#"id": "color_weight_blue",
			#"title": "Más azul",
			#"description": "+2 peso azul",
			#"family": "color_weight",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 80,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_COLOR_WEIGHT,
					#"color_id": 2,
					#"amount": 2
				#}
			#]
		#},
		#{
			#"id": "color_weight_yellow",
			#"title": "Más amarillo",
			#"description": "+2 peso amarillo",
			#"family": "color_weight",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 80,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_COLOR_WEIGHT,
					#"color_id": 3,
					#"amount": 2
				#}
			#]
		#},
		#{
			#"id": "bonus_chance_red",
			#"title": "Brillo rojo",
			#"description": "+10 % BONUS rojo",
			#"family": "bonus_chance_color",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 100,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_BONUS_CHANCE,
					#"color_id": 0,
					#"amount": 0.1
				#}
			#]
		#},
		#{
			#"id": "bonus_chance_green",
			#"title": "Brillo verde",
			#"description": "+10 % BONUS verde",
			#"family": "bonus_chance_color",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 100,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_BONUS_CHANCE,
					#"color_id": 1,
					#"amount": 0.1
				#}
			#]
		#},
		#{
			#"id": "bonus_chance_blue",
			#"title": "Brillo azul",
			#"description": "+10 % BONUS azul",
			#"family": "bonus_chance_color",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 100,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_BONUS_CHANCE,
					#"color_id": 2,
					#"amount": 0.1
				#}
			#]
		#},
		#{
			#"id": "bonus_chance_yellow",
			#"title": "Brillo amarillo",
			#"description": "+10 % BONUS amarillo",
			#"family": "bonus_chance_color",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 100,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_BONUS_CHANCE,
					#"color_id": 3,
					#"amount": 0.1
				#}
			#]
		#},
		#{
			#"id": "bonus_gem_points_bonus",
			#"max_stacks": -1,
			#"title": "Bonus +5 puntos",
			#"description": "Bonificación de BONUS aumenta +5 puntos",
			#"family": "bonus_gem_points_bonus",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 70,
			#"occupies_slot": true,
			#"modifier_id": "bonus_gem_points_bonus",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_BONUS_GEM_POINTS_BONUS,
					#"amount": 5
				#}
			#]
		#},
		#{
			#"id": "bonus_gem_score_engine",
			#"max_stacks": 1,
			#"title": "Cada BONUS acumula 1 carga",
			#"description": "La bonificacion de BONUS aumenta +1 por cada carga",
			#"family": "bonus_gem_score_engine",
			#"rarity": RewardRarity.Type.RARE,
			#"family_weight": 60,
			#"occupies_slot": true,
			#"modifier_id": "bonus_gem_score_engine",
			#"effects": []
		#},
		#{
			#"id": "multi_chance_red",
			#"title": "MULTI rojo",
			#"description": "+5 % MULTI rojo",
			#"family": "multi_chance_color",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 60,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_MULTI_CHANCE,
					#"color_id": 0,
					#"amount": 0.05
				#}
			#]
		#},
		#{
			#"id": "multi_chance_green",
			#"title": "MULTI verde",
			#"description": "+5 % MULTI verde",
			#"family": "multi_chance_color",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 60,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_MULTI_CHANCE,
					#"color_id": 1,
					#"amount": 0.05
				#}
			#]
		#},
		#{
			#"id": "multi_chance_blue",
			#"title": "MULTI azul",
			#"description": "+5 % MULTI azul",
			#"family": "multi_chance_color",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 60,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_MULTI_CHANCE,
					#"color_id": 2,
					#"amount": 0.05
				#}
			#]
		#},
		#{
			#"id": "multi_chance_yellow",
			#"title": "MULTI amarillo",
			#"description": "+5 % MULTI amarillo",
			#"family": "multi_chance_color",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 60,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_MULTI_CHANCE,
					#"color_id": 3,
					#"amount": 0.05
				#}
			#]
		#},
		#{
			#"id": "multi_gem_multiplier_bonus",
			#"max_stacks": -1,
			#"title": "MULTI +0.1 multiplicador",
			#"description": "El multiplicador de MULTI aumenta +0.1",
			#"family": "multi_gem_multiplier_bonus",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 50,
			#"occupies_slot": true,
			#"modifier_id": "multi_gem_multiplier_bonus",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_MULTI_GEM_MULTIPLIER_BONUS,
					#"amount": 0.1
				#}
			#]
		#},
		#{
			#"id": "color_weight_and_bonus_chance_red",
			#"title": "Afinidad roja",
			#"description": "+1 peso rojo\n+5 % BONUS rojo",
			#"family": "color_weight_and_bonus_chance_color",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 100,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_COLOR_WEIGHT,
					#"color_id": 0,
					#"amount": 1
				#},
				#{
					#"type": RewardEffectType.Type.ADD_BONUS_CHANCE,
					#"color_id": 0,
					#"amount": 0.05
				#}
			#]
		#},
		#{
			#"id": "color_weight_and_bonus_chance_green",
			#"title": "Afinidad verde",
			#"description": "+1 peso verde\n+5 % BONUS verde",
			#"family": "color_weight_and_bonus_chance_color",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 100,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_COLOR_WEIGHT,
					#"color_id": 1,
					#"amount": 1
				#},
				#{
					#"type": RewardEffectType.Type.ADD_BONUS_CHANCE,
					#"color_id": 1,
					#"amount": 0.05
				#}
			#]
		#},
		#{
			#"id": "color_weight_and_bonus_chance_blue",
			#"title": "Afinidad azul",
			#"description": "+1 peso azul\n+5 % BONUS azul",
			#"family": "color_weight_and_bonus_chance_color",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 100,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_COLOR_WEIGHT,
					#"color_id": 2,
					#"amount": 1
				#},
				#{
					#"type": RewardEffectType.Type.ADD_BONUS_CHANCE,
					#"color_id": 2,
					#"amount": 0.05
				#}
			#]
		#},
		#{
			#"id": "color_weight_and_bonus_chance_yellow",
			#"title": "Afinidad amarilla",
			#"description": "+1 peso amarillo\n+5 % BONUS amarillo",
			#"family": "color_weight_and_bonus_chance_color",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 100,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_COLOR_WEIGHT,
					#"color_id": 3,
					#"amount": 1
				#},
				#{
					#"type": RewardEffectType.Type.ADD_BONUS_CHANCE,
					#"color_id": 3,
					#"amount": 0.05
				#}
			#]
		#},
		#{
			#"id": "color_score_red",
			#"title": "Potencia roja",
			#"description": "+10 % puntuación de matches rojos",
			#"family": "color_score",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 50,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_MATCH_SCORE_MULTIPLIER,
					#"color_id": 0,
					#"amount": 0.1
				#}
			#]
		#},
		#{
			#"id": "color_score_green",
			#"title": "Potencia verde",
			#"description": "+10 % puntuación de matches verdes",
			#"family": "color_score",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 50,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_MATCH_SCORE_MULTIPLIER,
					#"color_id": 1,
					#"amount": 0.1
				#}
			#]
		#},
		#{
			#"id": "color_score_blue",
			#"title": "Potencia azul",
			#"description": "+10 % puntuación de matches azules",
			#"family": "color_score",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 50,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_MATCH_SCORE_MULTIPLIER,
					#"color_id": 2,
					#"amount": 0.1
				#}
			#]
		#},
		#{
			#"id": "color_score_yellow",
			#"title": "Potencia amarillo",
			#"description": "+10 % puntuación de matches amarillo",
			#"family": "color_score",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 50,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_MATCH_SCORE_MULTIPLIER,
					#"color_id": 3,
					#"amount": 0.1
				#}
			#]
		#},
		#{
			#"id": "match4_engine_color_score_red",
			#"max_stacks": 1,
			#"title": "Crecimiento rojo",
			#"description": "Cada match de 4 rojas aumenta +5 % la puntuación de matches rojos",
			#"family": "match4_engine_color_score",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 60,
			#"occupies_slot": true,
			#"modifier_id": "match4_engine_red",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_MATCH_4_MULTIPLIER_GROWTH,
					#"color_id": 0,
					#"amount": 0.05
				#}
			#]
		#},
		#{
			#"id": "match4_engine_color_score_green",
			#"max_stacks": 1,
			#"title": "Crecimiento verde",
			#"description": "Cada match de 4 verdes aumenta +5 % la puntuación de matches verdes",
			#"family": "match4_engine_color_score",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 60,
			#"occupies_slot": true,
			#"modifier_id": "match4_engine_green",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_MATCH_4_MULTIPLIER_GROWTH,
					#"color_id": 1,
					#"amount": 0.05
				#}
			#]
		#},
		#{
			#"id": "match4_engine_color_score_blue",
			#"max_stacks": 1,
			#"title": "Crecimiento azul",
			#"description": "Cada match de 4 azules aumenta +5 % la puntuación de matches azules",
			#"family": "match4_engine_color_score",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 60,
			#"occupies_slot": true,
			#"modifier_id": "match4_engine_blue",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_MATCH_4_MULTIPLIER_GROWTH,
					#"color_id": 2,
					#"amount": 0.05
				#}
			#]
		#},
		#{
			#"id": "match4_engine_color_score_yellow",
			#"max_stacks": 1,
			#"title": "Crecimiento amarillo",
			#"description": "Cada match de 4 amarillas aumenta +5 % la puntuación de matches amarillos",
			#"family": "match4_engine_color_score",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 60,
			#"occupies_slot": true,
			#"modifier_id": "match4_engine_yellow",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_MATCH_4_MULTIPLIER_GROWTH,
					#"color_id": 3,
					#"amount": 0.05
				#}
			#]
		#},
		#{
			#"id": "l_shape_score_growth",
			#"max_stacks": 1,
			#"title": "Crecimiento en L",
			#"description": "Cada L aumenta en 10 la puntuación base de futuras L.",
			#"family": "matchL_score_engine",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 60,
			#"occupies_slot": true,
			#"modifier_id": "matchL_score_engine",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_L_SHAPE_SCORE_GROWTH,
					#"amount": 10
				#}
			#]
		#},
		#{
			#"id": "T_shape_score_growth",
			#"max_stacks": 1,
			#"title": "Crecimiento en T",
			#"description": "Cada T aumenta en 10 la puntuación base de futuras T.",
			#"family": "matchT_score_engine",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 60,
			#"occupies_slot": true,
			#"modifier_id": "matchT_score_engine",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_T_SHAPE_SCORE_GROWTH,
					#"amount": 10
				#}
			#]
		#},
		#{
			#"id": "CROSS_shape_score_growth",
			#"max_stacks": 1,
			#"title": "Crecimiento en CRUZ",
			#"description": "Cada + aumenta en 10 la puntuación base de futuras +.",
			#"family": "matchCROSS_score_engine",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 60,
			#"occupies_slot": true,
			#"modifier_id": "matchCROSS_score_engine",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_CROSS_SHAPE_SCORE_GROWTH,
					#"amount": 10
				#}
			#]
		#},
		#{
			#"id": "bomb_match_4",
			#"max_stacks": 1,
			#"title": "Match 4 -> BOMB",
			#"description": "Un match de 4 genera una BOMB",
			#"family": "bomb_generator",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 80,
			#"occupies_slot": true,
			#"modifier_id": "bomb_generator",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ENABLE_BOMB_MATCH_4
				#}
			#]
		#},
		#{
			#"id": "bomb_match_5",
			#"max_stacks": 1,
			#"title": "Match 5 -> BOMB",
			#"description": "Un match de 5 genera una BOMB",
			#"family": "bomb_generator",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 80,
			#"occupies_slot": true,
			#"modifier_id": "bomb_generator",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ENABLE_BOMB_MATCH_5
				#}
			#],
			#"requirements": [
				#{
					#"type": RewardRequirementType.Type.HAS_REWARD,
					#"reward_id": "bomb_match_4"
				#},
				#{
					#"type": RewardRequirementType.Type.MATCH_DISCOVERED,
					#"match_type": MatchType.Type.MATCH_5_PLUS
				#}
			#]
		#},
		#{
			#"id": "bomb_match_L",
			#"max_stacks": 1,
			#"title": "Match L -> BOMB",
			#"description": "Un match de L genera una BOMB",
			#"family": "bomb_generator",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 80,
			#"occupies_slot": true,
			#"modifier_id": "bomb_generator",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ENABLE_BOMB_MATCH_L
				#}
			#],
			#"requirements": [
				#{
					#"type": RewardRequirementType.Type.HAS_REWARD,
					#"reward_id": "bomb_match_4"
				#},
				#{
					#"type": RewardRequirementType.Type.MATCH_DISCOVERED,
					#"match_type": MatchType.Type.L
				#}
			#]
		#},
		#{
			#"id": "bomb_match_T",
			#"max_stacks": 1,
			#"title": "Match T -> BOMB",
			#"description": "Un match de T genera una BOMB",
			#"family": "bomb_generator",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 80,
			#"occupies_slot": true,
			#"modifier_id": "bomb_generator",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ENABLE_BOMB_MATCH_T
				#}
			#],
			#"requirements": [
				#{
					#"type": RewardRequirementType.Type.HAS_REWARD,
					#"reward_id": "bomb_match_4"
				#},
				#{
					#"type": RewardRequirementType.Type.MATCH_DISCOVERED,
					#"match_type": MatchType.Type.T
				#}
			#]
		#},
		#{
			#"id": "bomb_match_CROSS",
			#"max_stacks": 1,
			#"title": "Match CROSS -> BOMB",
			#"description": "Un match de CROSS genera una BOMB",
			#"family": "bomb_generator",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 80,
			#"occupies_slot": true,
			#"modifier_id": "bomb_generator",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ENABLE_BOMB_MATCH_CROSS
				#}
			#],
			#"requirements": [
				#{
					#"type": RewardRequirementType.Type.HAS_REWARD,
					#"reward_id": "bomb_match_4"
				#},
				#{
					#"type": RewardRequirementType.Type.MATCH_DISCOVERED,
					#"match_type": MatchType.Type.CROSS
				#}
			#]
		#},
		#{
			#"id": "bomb_points_stacker",
			#"title": "Pólvora",
			#"description": "Cada BOMB genera +1 de polvora. La puntuación de BOMB se aumenta el valor de la pólvora",
			#"family": "bomb_points_stacker",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 20,
			#"occupies_slot": true,
			#"modifier_id": "bomb_points_stacker",
			#"max_stacks": 1,
			#"effects": []
		#},
		#{
			#"id": "bomb_chain_multiplier",
			#"max_stacks": 1,
			#"title": "Cadena BOMB",
			#"description": "Cada BOMB detonada por otra aumenta en +1 el multiplicador de puntuación BOMB de esa resolución.",
			#"family": "bomb_chain",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 50,
			#"occupies_slot": true,
			#"modifier_id": "bomb_chain_multiplier",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_BOMB_CHAIN_MULTIPLIER_GROWTH,
					#"amount": 1.0
				#}
			#]
		#},
		#{
			#"id": "bomb_chain_multiplier_upgrade",
			#"max_stacks": -1,
			#"title": "Cadena BOMB plus",
			#"description": "Cada BOMB detonada por otra aumenta en 0.2 el multiplicador de puntuación BOMB de esa resolución.",
			#"family": "bomb_chain",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 30,
			#"occupies_slot": true,
			#"modifier_id": "bomb_chain_multiplier",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_BOMB_CHAIN_MULTIPLIER_GROWTH,
					#"amount": 0.2
				#}
			#],
			#"requirements": [
				#{
					#"type": RewardRequirementType.Type.HAS_REWARD,
					#"reward_id": "bomb_chain_multiplier"
				#}
			#]
		#},
		#{
			#"id": "cascade_match_score_bonus",
			#"max_stacks": -1,
			#"title": "Crecimiento de cascada",
			#"description": "Cada match en cascada da +10 puntos",
			#"family": "cascade_match_score_bonus",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 70,
			#"occupies_slot": true,
			#"modifier_id": "cascade_match_score_bonus",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_CASCADE_MATCH_SCORE_BONUS,
					#"amount": 10
				#}
			#]
		#},
		#{
			#"id": "cascade_match_score_multiplier",
			#"max_stacks": 1,
			#"title": "Multiplicador en cascada",
			#"description": "Los match en cascada obtienen un multiplicador x2",
			#"family": "cascade_match_score_multiplier",
			#"rarity": RewardRarity.Type.RARE,
			#"family_weight": 70,
			#"occupies_slot": true,
			#"modifier_id": "cascade_match_score_multiplier",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_CASCADE_MATCH_SCORE_MULTIPLIER,
					#"amount": 1.0
				#}
			#]
		#},
		#{
			#"id": "cascade_match_score_multiplier_upgrade",
			#"max_stacks": -1,
			#"title": "Mejora de multiplicador en cascada",
			#"description": "El multiplicador de los match en cascada aumenta un 0.2",
			#"family": "cascade_match_score_multiplier",
			#"rarity": RewardRarity.Type.RARE,
			#"family_weight": 70,
			#"occupies_slot": true,
			#"modifier_id": "cascade_match_score_multiplier",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_CASCADE_MATCH_SCORE_MULTIPLIER,
					#"amount": 0.2
				#}
			#],
			#"requirements": [
				#{
					#"type": RewardRequirementType.Type.HAS_REWARD,
					#"reward_id": "cascade_match_score_multiplier"
				#}
			#]
		#},
		#{
			#"id": "cascade_special_type_score_bonus",
			#"max_stacks": -1,
			#"title": "Especiales en cascada",
			#"description": "Cada SpecialType eliminado en cascada da +10 puntos",
			#"family": "cascade_special_type_score_bonus",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 60,
			#"occupies_slot": true,
			#"modifier_id": "cascade_special_type_score_bonus",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_CASCADE_SPECIAL_TYPE_SCORE_BONUS,
					#"amount": 10
				#}
			#]
		#},
		#{
			#"id": "match3_level_engine",
			#"max_stacks": 1,
			#"title": "M3 sube de nivel",
			#"description": "Cada M3 aumenta +1 su nivel",
			#"family": "match3_level_engine",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 50,
			#"occupies_slot": true,
			#"modifier_id": "match3_level_engine",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_SCORING_LEVEL_GROWTH,
					#"scoring_source": ScoreManagerScript.ScoringSource.MATCH_3,
					#"amount": 1
				#}
			#]
		#},
		#{
			#"id": "match4_level_engine",
			#"max_stacks": 1,
			#"title": "M4 sube de nivel",
			#"description": "Cada M4 aumenta +1 su nivel",
			#"family": "match4_level_engine",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 50,
			#"occupies_slot": true,
			#"modifier_id": "match4_level_engine",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_SCORING_LEVEL_GROWTH,
					#"scoring_source": ScoreManagerScript.ScoringSource.MATCH_4,
					#"amount": 1
				#}
			#]
		#},
		#{
			#"id": "match5_level_engine",
			#"max_stacks": 1,
			#"title": "M5 sube de nivel",
			#"description": "Cada M5 aumenta +1 su nivel",
			#"family": "match5_level_engine",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 50,
			#"occupies_slot": true,
			#"modifier_id": "match5_level_engine",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_SCORING_LEVEL_GROWTH,
					#"scoring_source": ScoreManagerScript.ScoringSource.MATCH_5_PLUS,
					#"amount": 1
				#}
			#]
		#},
		#{
			#"id": "matchL_level_engine",
			#"max_stacks": 1,
			#"title": "ML sube de nivel",
			#"description": "Cada ML aumenta +1 su nivel",
			#"family": "matchL_level_engine",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 50,
			#"occupies_slot": true,
			#"modifier_id": "matchL_level_engine",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_SCORING_LEVEL_GROWTH,
					#"scoring_source": ScoreManagerScript.ScoringSource.L_SHAPE,
					#"amount": 1
				#}
			#]
		#},
		#{
			#"id": "matchT_level_engine",
			#"max_stacks": 1,
			#"title": "MT sube de nivel",
			#"description": "Cada MT aumenta +1 su nivel",
			#"family": "matchT_level_engine",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 50,
			#"occupies_slot": true,
			#"modifier_id": "matchT_level_engine",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_SCORING_LEVEL_GROWTH,
					#"scoring_source": ScoreManagerScript.ScoringSource.T_SHAPE,
					#"amount": 1
				#}
			#]
		#},
		#{
			#"id": "match_cross_level_engine",
			#"max_stacks": 1,
			#"title": "MCross sube de nivel",
			#"description": "Cada MCross aumenta +1 su nivel",
			#"family": "matchCross_level_engine",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 50,
			#"occupies_slot": true,
			#"modifier_id": "matchCross_level_engine",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_SCORING_LEVEL_GROWTH,
					#"scoring_source": ScoreManagerScript.ScoringSource.CROSS_SHAPE,
					#"amount": 1
				#}
			#]
		#},
		#{
			#"id": "bomb_level_engine",
			#"max_stacks": 1,
			#"title": "BOMB sube de nivel",
			#"description": "Cada BOMB detonada aumenta +1 su nivel",
			#"family": "bomb_level_engine",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 100,
			#"occupies_slot": true,
			#"modifier_id": "bomb_level_engine",
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_SCORING_LEVEL_GROWTH,
					#"scoring_source": ScoreManagerScript.ScoringSource.BOMB,
					#"amount": 1
				#}
			#]
		#},
		#{
			#"id": "milestone_bonus_buff",
			#"title": "Bonus al BONUS",
			#"description": "+5% BONUS y +25 puntos al BONUS",
			#"family": "milestone_bonus_buff",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 1,
			#"occupies_slot": false,
			#"source": RewardSource.Type.MILESTONE,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_BONUS_CHANCE,
					#"color_id": 0,
					#"amount": 0.05
				#},
				#{
					#"type": RewardEffectType.Type.ADD_BONUS_CHANCE,
					#"color_id": 1,
					#"amount": 0.05
				#},
				#{
					#"type": RewardEffectType.Type.ADD_BONUS_CHANCE,
					#"color_id": 2,
					#"amount": 0.05
				#},
				#{
					#"type": RewardEffectType.Type.ADD_BONUS_CHANCE,
					#"color_id": 3,
					#"amount": 0.05
				#},
				#{
					#"type": RewardEffectType.Type.ADD_BONUS_GEM_POINTS_BONUS,
					#"amount": 25
				#}
			#]
		#},
		#{
			#"id": "milestone_color_weight_and_bonus_and_multi_chance_red",
			#"title": "Lagarto de fuego",
			#"description": "+3 peso rojo\n+10 % BONUS rojo\n+5 % MULTI rojo",
			#"family": "milestone_color_weight_and_bonus_and_multi_chance_color",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 1,
			#"occupies_slot": false,
			#"source": RewardSource.Type.MILESTONE,
			#"max_stacks": 1,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_COLOR_WEIGHT,
					#"color_id": 0,
					#"amount": 3
				#},
				#{
					#"type": RewardEffectType.Type.ADD_BONUS_CHANCE,
					#"color_id": 0,
					#"amount": 0.10
				#},
				#{
					#"type": RewardEffectType.Type.ADD_MULTI_CHANCE,
					#"color_id": 0,
					#"amount": 0.05
				#}
			#]
		#},
		#{
			#"id": "milestone_color_weight_and_bonus_and_multi_chance_green",
			#"title": "Rana de planta",
			#"description": "+3 peso verde\n+10 % BONUS verde\n+5 % MULTI verde",
			#"family": "milestone_color_weight_and_bonus_and_multi_chance_color",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 1,
			#"occupies_slot": false,
			#"source": RewardSource.Type.MILESTONE,
			#"max_stacks": 1,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_COLOR_WEIGHT,
					#"color_id": 1,
					#"amount": 3
				#},
				#{
					#"type": RewardEffectType.Type.ADD_BONUS_CHANCE,
					#"color_id": 1,
					#"amount": 0.10
				#},
				#{
					#"type": RewardEffectType.Type.ADD_MULTI_CHANCE,
					#"color_id": 1,
					#"amount": 0.05
				#}
			#]
		#},
		#{
			#"id": "milestone_color_weight_and_bonus_and_multi_chance_blue",
			#"title": "Tortuga de agua",
			#"description": "+3 peso azul\n+10 % BONUS azul\n+5 % MULTI azul",
			#"family": "milestone_color_weight_and_bonus_and_multi_chance_color",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 1,
			#"occupies_slot": false,
			#"source": RewardSource.Type.MILESTONE,
			#"max_stacks": 1,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_COLOR_WEIGHT,
					#"color_id": 2,
					#"amount": 3
				#},
				#{
					#"type": RewardEffectType.Type.ADD_BONUS_CHANCE,
					#"color_id": 2,
					#"amount": 0.10
				#},
				#{
					#"type": RewardEffectType.Type.ADD_MULTI_CHANCE,
					#"color_id": 2,
					#"amount": 0.05
				#}
			#]
		#},
		#{
			#"id": "milestone_color_weight_and_bonus_and_multi_chance_yellow",
			#"title": "Ratón eléctrico",
			#"description": "+3 peso amarillo\n+10 % BONUS amarillo\n+5 % MULTI amarillo",
			#"family": "milestone_color_weight_and_bonus_and_multi_chance_color",
			#"rarity": RewardRarity.Type.UNCOMMON,
			#"family_weight": 1,
			#"occupies_slot": false,
			#"source": RewardSource.Type.MILESTONE,
			#"max_stacks": 1,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_COLOR_WEIGHT,
					#"color_id": 3,
					#"amount": 3
				#},
				#{
					#"type": RewardEffectType.Type.ADD_BONUS_CHANCE,
					#"color_id": 3,
					#"amount": 0.10
				#},
				#{
					#"type": RewardEffectType.Type.ADD_MULTI_CHANCE,
					#"color_id": 3,
					#"amount": 0.05
				#}
			#]
		#},
		#{
			#"id": "milestone_extra_moves",
			#"title": "Tiempo extra",
			#"description": "+1 movimiento al inicio de cada encuentro",
			#"family": "milestone_extra_moves",
			#"rarity": RewardRarity.Type.COMMON,
			#"family_weight": 1,
			#"occupies_slot": false,
			#"source": RewardSource.Type.MILESTONE,
			#"max_stacks": 3,
			#"effects": [
				#{
					#"type": RewardEffectType.Type.ADD_STARTING_MOVES,
					#"amount": 1
				#}
			#]
		#}
	#]
