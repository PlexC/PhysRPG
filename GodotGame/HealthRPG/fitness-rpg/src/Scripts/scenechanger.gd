extends Node

var pending_spawn_name: String = ""
var has_seen_tutorial: bool = false
var is_boss_battle: bool = false
var pending_enemy_data: Array = []
var _player: AudioStreamPlayer
var _current_track_path: String = ""
var is_walking: bool = false

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

	if has_node("/root/Load"):
		await Load.fade_to_game()


func start_random_battle(weighted_pool: Dictionary) -> void:
	is_boss_battle = false
	# 1. Pick 3 random enemies based on weights
	var enemies = []
	for i in range(3):
		enemies.append(_pick_weighted_enemy(weighted_pool))
	
	_start_battle_internal(enemies) # Reuse the same logic


func _pick_weighted_enemy(pool: Dictionary) -> BattleActor:
	var total_weight = 0
	for key in pool:
		total_weight += pool[key]
	
	var roll = randi_range(0, total_weight)
	var current = 0
	
	for key in pool:
		current += pool[key]
		if roll <= current:
			# Return a DUPLICATE of the enemy data so we don't break the original
			return Savemanager.enemies[key].duplicate_custom()
	
	return Savemanager.enemies.values()[0].duplicate_custom() # Fallback


func _heal_all_party() -> void:
	for member in Savemanager.party:
		member.hp = member.hp_max
		# member.mp = member.mp_max
	print("Party fully healed.")


func _start_battle_internal(squad: Array) -> void:
	pending_enemy_data = squad
