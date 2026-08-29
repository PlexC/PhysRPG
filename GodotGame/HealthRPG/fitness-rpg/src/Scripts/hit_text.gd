extends Label

const SPEED:float = 0.05

func _process(delta: float) -> void:
	position.y -= SPEED*5

func _on_free_timeout() -> void:
	queue_free()
