extends TextureRect

#@onready var length: float = size.x
#@onready var atlas_length: float = texture.atlas.get_size().x
@onready var frame_width: float = texture.region.size.x
@onready var sheet_width: float = texture.atlas.get_width()
@export var base_offset: Vector2 = Vector2(0, 18.5)
@onready var size_offset: Vector2 = texture.get_size() * -0.5

@export var follow_viewport_focus: bool = false

var target: Node = null
var offset: Vector2

func _ready() -> void:
	#print(length)
	#print(atlas_length)
	var reset_region = texture.region
	reset_region.position.x = 0
	texture.region = reset_region
	
	offset = base_offset + size_offset
	if follow_viewport_focus:
		get_viewport().gui_focus_changed.connect(_on_viewport_gui_focus_changed)
	
	stop()


func _process(_delta: float) -> void:
	global_position = target.global_position + Vector2(offset.x, offset.y + target.size.y * 0.5)


func _on_frame_advance_timeout() -> void:
	#texture.region.position.x += length
	#texture.region.position.x = wrapf(texture.region.position.x,0,atlas_length)
	var current_region = texture.region
	current_region.position.x += frame_width
	if current_region.position.x >= sheet_width:
		current_region.position.x = 0
	texture.region = current_region


	

func update_target(node: Control) -> void:
	#print(node.name)
	if node is BaseButton:
		if target:
			target.tree_exiting.disconnect(_on_target_tree_exiting)
			target.focus_exited.disconnect(_on_target_focus_exited)
		
		target = node
		
		if !target.tree_exiting.is_connected(_on_target_tree_exiting):
			target.tree_exiting.connect(_on_target_tree_exiting.bind(target))
			target.focus_exited.connect(_on_target_focus_exited.bind(target))
		
		show()
		set_process(true)
		#animation_player.play("RESET")
	else:
		stop()

func stop() -> void:
	target = null
	set_process(false)
	hide()

func _on_viewport_gui_focus_changed(node: Control) -> void:
	update_target(node)

func _on_menu_button_focused(button: BaseButton, _index: int) -> void:
	update_target(button)

func _on_target_tree_exiting(node: Control) -> void:
	if node == target:
		stop()

func _on_target_focus_exited(node: Control) -> void:
	if node == target:
		if follow_viewport_focus:
			stop()
		else:
			hide()
#			animation_player.play("blink")

func _on_menu_closed() -> void:
	await(get_tree().process_frame)
	stop()
