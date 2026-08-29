class_name EnemyButton extends BattleActorButton

signal atb_ready()

@onready var _atb_bar = $ATBbar

func _ready() -> void:
	pass

func reset()->void:
	_atb_bar.reset()

func _on_at_bbar_filled() -> void:
	atb_ready.emit()
	#_atb_bar.reset()

func _on_data_defeated()->void:
	_atb_bar.stop()
	await get_tree().create_timer(1.0).timeout
	queue_free()
