extends Node2D


const GEM_SCENE = preload("res://scenes/Gem.tscn")
const BOARD_SIZE = 8
const TILE_SIZE = 80
const BOARD_OFFSET = Vector2(50, 50)

var board = []

func _ready() -> void:
	for row in range(BOARD_SIZE):
		var row_data = []
		for column in range(BOARD_SIZE):
			var gem = GEM_SCENE.instantiate()
			gem.row = row
			gem.column = column
			gem.clicked.connect(_on_gem_clicked)
			gem.position = BOARD_OFFSET + Vector2(
				column * TILE_SIZE,
				row * TILE_SIZE
			)
			add_child(gem)
			row_data.append(gem)
		board.append(row_data)

func _on_gem_clicked(gem) -> void:
	print("Has seleccionado la gema (", gem.row, ", ", gem.column, ")")
