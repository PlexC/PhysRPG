class_name main extends Control


@onready var daily: Control = $Daily

@export var inv: Inventory


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Savemanager.save_game()
	daily.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_daily_b_pressed() -> void:
	if daily.visible == false:
		daily.visible = true
	else:
		daily.visible = false
