extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var anim = $AnimationPlayer
@onready var label = $Label

func _ready() -> void:
	# Keep it invisible during normal gameplay
	color_rect.visible = false
	label.visible = false

func fade_to_black() -> void:
	color_rect.visible = true
	label.visible = true
	anim.play("fade_in")
	await anim.animation_finished

func fade_to_game() -> void:
	anim.play("fade_out")
	await anim.animation_finished
	color_rect.visible = false
	label.visible = false
