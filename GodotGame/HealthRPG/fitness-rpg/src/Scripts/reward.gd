extends CanvasLayer

@export var type: Chest
@export var reward_item: Item
@export var inv: Inventory
@onready var chest_animation: AnimatedSprite2D = $Sprite2D/AnimatedSprite2D




enum Chest{
	WOOD,
	Dark,
	GOLD,
	BLUE
}


func _ready() -> void:
	visible = false


func get_reward():
	visible = true
	match type:
		Chest.WOOD:
			chest_animation.play("chest_open_wood")
		Chest.Dark:
			chest_animation.play("chest_open_dark")
		Chest.GOLD:
			chest_animation.play("chest_open_gold")
		Chest.BLUE:
			chest_animation.play("chest_open_blue")
	await chest_animation.animation_finished
	if reward_item:
		add_items(reward_item)
	visible = false

func random():
	pass

func add_items(item:Item):
	inv.insert(item)
