extends Node2D


const GEM_SCENE = preload("res://scenes/Gem.tscn")
const BOARD_SIZE = 8
const TILE_SIZE = 80
const BOARD_OFFSET = Vector2(50, 50)

var board = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for row in range(BOARD_SIZE):
		var row_data = []
		for column in range(BOARD_SIZE):
			var gem = GEM_SCENE.instantiate()
			gem.row = row
			gem.column = column
			gem.position = BOARD_OFFSET + Vector2(
				column * TILE_SIZE,
				row * TILE_SIZE
			)
			add_child(gem)
			row_data.append(gem)
		board.append(row_data)
	print(board[2][5].row, ", ", board[2][5].column)
