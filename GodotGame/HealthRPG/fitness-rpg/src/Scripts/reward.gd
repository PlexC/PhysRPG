extends CanvasLayer

@export var type: Chest

enum Chest{
	WOOD,
	Dark,
	GOLD,
	BLUE
}



func _ready() -> void:
	visible = false


func get_reward():
	pass
