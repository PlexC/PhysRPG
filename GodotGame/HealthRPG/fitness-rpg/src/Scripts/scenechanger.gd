class_name Gamemanager extends Node

#const PLAYER_SCENE := preload("res://src/Scenes/Core/Player.tscn")

var player: CharacterBody2D = null
var pending_spawn_name: String = ""
var has_seen_tutorial: bool = false

func _ready():
	# This fires EVERY time the scene changes
	get_tree().scene_changed.connect(_on_scene_changed)


func change_scene(target_scene_path: String, spawn_marker_name: String) -> void:
	pending_spawn_name = spawn_marker_name
	if has_node("/root/Load"):
		await Load.fade_to_black()
	get_tree().change_scene_to_file(target_scene_path)


func _on_scene_changed():
	# Wait one frame so nodes are fully ready
	await get_tree().process_frame

	if pending_spawn_name != "":
		spawn_player_at_marker(pending_spawn_name)
		pending_spawn_name = ""
	if has_node("/root/Load"):
		await Load.fade_to_game()


func spawn_player_at_marker(marker_name: String) -> void:
	var scene := get_tree().current_scene
	var marker := scene.get_node_or_null(marker_name)

	if marker == null:
		push_error("Spawn marker not found: " + marker_name)
		return

	#if player == null or not is_instance_valid(player):
		#player = PLAYER_SCENE.instantiate()
		#scene.add_child(player)
