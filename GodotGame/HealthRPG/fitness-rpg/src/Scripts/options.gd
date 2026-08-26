extends Control

@onready var inventory: Control = $Inventory

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_items_b_pressed() -> void:
	inventory.toggle()


func _on_skill_b_pressed() -> void:
	pass # Replace with function body.


func _on_save_b_pressed() -> void:
	pass # Replace with function body.


func _on_options_b_pressed() -> void:
	pass # Replace with function body.
