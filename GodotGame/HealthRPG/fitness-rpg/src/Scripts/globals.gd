extends Node

const  GAME_SIZE: Vector2 = Vector2(1725,1152)
const CELL_SIZE = Vector2(64, 64)

var textbox: Textbox = null

func _ready() -> void:
	randomize()
