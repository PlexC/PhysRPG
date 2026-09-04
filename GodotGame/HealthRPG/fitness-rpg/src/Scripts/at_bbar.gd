class_name ATBBar extends ProgressBar

signal filled()

const SPEED_BASE: float = 0.1

@export var speed_multiplier: float = 1.0
@onready var _anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	_anim.play("RESET")
	value = randf_range(min_value,max_value * 0.75)

func reset() -> void:
	value = min_value
	modulate = Color("ffffffff")
	set_process(true)	

func stop()->void:
	set_process(false)

func _process(_delta: float) -> void:
	value += SPEED_BASE*speed_multiplier

	if is_equal_approx(value, max_value):
		#get_theme_stylebox("fill").bg_color = Color("ff0000ff")
		modulate = Color("00fe00ff")
		#_anim.play("highlight")
		stop()
		filled.emit()
