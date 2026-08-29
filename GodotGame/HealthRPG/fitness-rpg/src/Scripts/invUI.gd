extends Control

#if need other places to have inventory
#@export var inv = Inventory
@onready var inv: Inventory = preload("res://src/Inv/player_inv.tres")
@onready var slots: Array = $Container/NinePatchRect/GridContainer.get_children()


var is_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inv.update.connect(update_slots)
	close()
	update_slots()

func toggle() -> void:
	if is_open:
		close()
	else:
		open()


func open() -> void:
	visible = true
	is_open = true

func close() -> void:
	visible = false
	is_open = false

func update_slots():
	for i in range(min(inv.slots.size(),slots.size())):
		slots[i].update(inv.slots[i])
