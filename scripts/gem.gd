class_name Gem
extends Node2D

signal clicked(gem)

@onready var sprite: Sprite2D = $Sprite2D
@onready var bonus_marker: Label = $BonusMarker
@onready var bomb_marker: Label = $BombMarker
@onready var multi_marker: Label = $MultiMarker

var row = -1
var column = -1
var color_id = -1
var is_selected = false
var special_type: SpecialType = SpecialType.NONE

enum SpecialType {
	NONE,
	BONUS,
	BOMB,
	MULTI
}

func set_color_id(new_color_id: int) -> void:
	color_id = new_color_id
	_update_visual()


func _update_visual() -> void:
	match color_id:
		0:
			$Sprite2D.modulate = Color.RED
		1:
			$Sprite2D.modulate = Color.GREEN
		2:
			$Sprite2D.modulate = Color.BLUE
		3:
			$Sprite2D.modulate = Color.YELLOW
	if is_selected:
		sprite.scale = Vector2(1.1, 1.1)
	else:
		sprite.scale = Vector2.ONE


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void: \
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)


func set_selected(selected: bool) -> void:
	is_selected = selected
	_update_visual()


func _update_special_visual() -> void:
	bonus_marker.visible = special_type == SpecialType.BONUS
	bomb_marker.visible = special_type == SpecialType.BOMB
	multi_marker.visible = special_type == SpecialType.MULTI


func set_special_type(new_special_type: SpecialType) -> void:
	special_type = new_special_type
	_update_special_visual()
