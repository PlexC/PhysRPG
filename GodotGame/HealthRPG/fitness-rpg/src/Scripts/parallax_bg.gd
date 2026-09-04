extends ParallaxBackground


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Scenechanger.is_walking: scroll_offset.x -= 100 * delta
	#print("Background is moving! Offset: ", scroll_offset.x)
