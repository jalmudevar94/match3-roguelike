extends CanvasLayer

@onready var score_label: Label = %ScoreLabel
@onready var moves_label: Label = %MovesLabel
@onready var result_panel: PanelContainer = %ResultPanel
@onready var result_label: Label = %ResultLabel

@onready var color_probabilities_label: Label = %ColorProbabilitiesLabel
@onready var bonus_probabilities_label: Label = %BonusProbabilitiesLabel
@onready var multi_probabilities_label: Label = %MultiProbabilitiesLabel
@onready var scoring_levels_label: Label = %ScoringLevelsLabel

@onready var encounter_label: Label = %EncounterLabel
@onready var boss_title_label: Label = %BossTitleLabel
@onready var boss_description_label: Label = %BossDescriptionLabel

@onready var reward_buttons_container: VBoxContainer = %RewardButtonsContainer
@onready var reward_buttons: Array[Button] = [
	%RewardButton0,
	%RewardButton1,
	%RewardButton2,
	%RewardButton3
]
@onready var restart_button: Button = %RestartButton

@onready var coins_label: Label = %CoinsLabel
@onready var roll_button: Button = %RollButton
@onready var upgrade_buttons: Array[Button] = [
	%UpgradeButton0,
	%UpgradeButton1,
	%UpgradeButton2,
]

signal restart_requested

signal reward_selected(option_index: int)
signal reward_passed

signal upgrade_roll_requested
signal upgrade_selected(option_index: int)

const COLOR_NAMES: Array[String] = [
	"Rojo",
	"Verde",
	"Azul",
	"Amarillo"
]

const SCORING_SOURCE_NAMES: Array[String] = [
	"M3",
	"M4",
	"M5+",
	"L",
	"T",
	"CROSS",
	"BOMB"
]


func _ready() -> void:
	result_panel.visible = false
	clear_upgrade_options()


func set_score(current_score: int, target_score: int) -> void:
	score_label.text = ("Puntuación: " + str(current_score) + " / " + str(target_score))


func set_moves_remaining(moves_remaining: int) -> void:
	moves_label.text = "Movimientos: " + str(moves_remaining)


func set_color_probabilities(probabilities: Array[float]) -> void:
	var text: String = ""
	
	for color_id in range(probabilities.size()):
		var percentage: float = probabilities[color_id] * 100.0
		text += "%s %.1f %%\n" % [ COLOR_NAMES[color_id], percentage ]
	
	color_probabilities_label.text = str(text)


func set_bonus_gem_chances(chances: Array[float]) -> void:
	var text: String = ""

	for color_id in range(chances.size()):
		var percentage: float = chances[color_id] * 100.0
		text += "BONUS %s: %.1f %%\n" % [
			COLOR_NAMES[color_id],
			percentage
		]

	bonus_probabilities_label.text = text


func set_multi_gem_chances(chances: Array[float]) -> void:
	var text: String = ""

	for color_id in range(chances.size()):
		var percentage: float = chances[color_id] * 100.0
		text += "MULTI %s: %.1f %%\n" % [
			COLOR_NAMES[color_id],
			percentage
		]

	multi_probabilities_label.text = text


func set_scoring_levels(levels: Dictionary) -> void:
	var text: String = "NIVELES\n"

	for source in range(SCORING_SOURCE_NAMES.size()):
		text += "%s: Lv.%d\n" % [
			SCORING_SOURCE_NAMES[source],
			levels[source]
		]

	scoring_levels_label.text = text


func set_encounter(current_encounter: int, is_special: bool) -> void:
	if is_special:
		encounter_label.text = "Encuentro %d — BOSS" % current_encounter
	else:
		encounter_label.text = "Encuentro %d" % current_encounter


func set_block_boss(
	title: String,
	description: String,
	is_active: bool
) -> void:
	if is_active:
		boss_title_label.text = "BOSS: " + title
	else:
		boss_title_label.text = "Próximo boss: " + title

	boss_description_label.text = description


func show_encounter_victory() -> void:
	result_label.text = "¡Victoria!"
	reward_buttons_container.show()
	restart_button.hide()
	result_panel.show()


func show_encounter_defeat() -> void:
	result_label.text = "Derrota"
	reward_buttons_container.hide()
	restart_button.text = "Reiniciar"
	restart_button.show()
	result_panel.show()


func show_run_completed() -> void:
	result_label.text = "¡Run completada!"
	reward_buttons_container.hide()
	restart_button.text = "Nueva run"
	restart_button.show()
	result_panel.show()


func show_result(victory:bool) -> void:
	
	result_label.text = "¡Victoria!" if victory else "Derrota"
	
	result_panel.visible = true
	
	if victory:
		reward_buttons_container.visible = true
		restart_button.visible = false
	else:
		reward_buttons_container.visible = false
		restart_button.visible = true


func hide_result() -> void:
	result_panel.visible = false


func _on_restart_button_pressed() -> void:
	restart_requested.emit()


func _on_reward_button_0_pressed() -> void:
	reward_selected.emit(0)


func _on_reward_button_1_pressed() -> void:
	reward_selected.emit(1)


func _on_reward_button_2_pressed() -> void:
	reward_selected.emit(2)


func _on_reward_button_3_pressed() -> void:
	reward_selected.emit(3)


func _on_pass_button_pressed() -> void:
	reward_passed.emit()


func set_reward_options(options: Array[RewardDefinition]) -> void:
	assert(
		options.size() <= reward_buttons.size(),
		"No hay suficientes botones para mostrar las recompensas"
	)

	for option_index in range(reward_buttons.size()):
		var button: Button = reward_buttons[option_index]

		if option_index < options.size():
			var reward: RewardDefinition = options[option_index]
			button.text = "%s\n%s" % [
				reward.title,
				reward.description
			]
			button.show()
		else:
			button.hide()


func show_modifier_replacement_options(
	modifier_slots: Array[ModifierInstance]
) -> void:
	result_label.text = "Elige una mejora para reemplazar"

	for slot_index in range(reward_buttons.size()):
		var button: Button = reward_buttons[slot_index]
		var modifier: ModifierInstance = modifier_slots[slot_index]

		if modifier == null:
			button.text = "Slot vacío"
		else:
			button.text = modifier.modifier_id

		button.show()


func set_coins(amount: int) -> void:
	coins_label.text = "Monedas: %d" % amount


func set_upgrade_roll_cost(cost: int, can_afford: bool) -> void:
	roll_button.text = "Tirada (%d)" % cost
	roll_button.disabled = not can_afford


func set_upgrade_options(options: Array[RewardDefinition]) -> void:
	for i in range(upgrade_buttons.size()):
		var button := upgrade_buttons[i]

		if i < options.size():
			button.text = options[i].title
			button.show()
			button.disabled = false
		else:
			button.hide()


func clear_upgrade_options() -> void:
	for button in upgrade_buttons:
		button.text = ""
		button.hide()


func _on_roll_button_pressed() -> void:
	upgrade_roll_requested.emit()


func _on_upgrade_button_0_pressed() -> void:
	upgrade_selected.emit(0)


func _on_upgrade_button_1_pressed() -> void:
	upgrade_selected.emit(1)


func _on_upgrade_button_2_pressed() -> void:
	upgrade_selected.emit(2)
