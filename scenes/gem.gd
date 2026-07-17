extends Node2D

signal clicked(gem)

var row = -1
var column = -1

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void: \
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)
