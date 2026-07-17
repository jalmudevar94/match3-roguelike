extends Node2D

signal clicked(gem)

var row = -1
var column = -1

#@onready var area = $Area2D
#
#func _ready():
	#area.input_event.connect(_on_area_2d_input_event)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void: \
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
	print("Click en ", row, ", ", column)
