extends Node
# its local cus user (saved into godot app_userdata foulder)
const SETTINGS_FILE = "user://settings.dat"
const GAME_FILE = "user://savegame.dat"

#saves
var settings = {
	"master_volume": 0.5,
	"timer": 0,
	"webcam": true,  
	"tutoriel": false,
	"camera_name":""
}

var game_state = {
	"current_scene": "res://src/Scenes/start.tscn",
	"skills": {
		"headbutt": true,
		"punch": true,
		"kick": true,
		"knee_smash": false,
		"elbow" : false,
		"secret_1": true
	},
	"inventory": {
		"slot1": ["",0],
		"slot2": ["",0],
		"slot3": ["",0],
		"slot4": ["",0],
		"slot5": ["",0],
		"slot6": ["",0],
		"slot7": ["",0],
		"slot8": ["",0],
		"slot9": ["",0]
	},
	"player": {
		"hp": 10,
		"xp": 0,
		"max_hp": 100,
		"level": 1
	}
}

var daily = {
	"tasks": {
		"do_10_squats": false, 
		"login": true
	}
}

func _ready() -> void:
	load_settings()

func save_settings() -> void:
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	file.store_var(settings)
	file.close()

func load_settings() -> void:
	if FileAccess.file_exists(SETTINGS_FILE):
		var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
		settings = file.get_var()
		file.close()

#temp add more stuff later
func save_game() -> void:
	#game_state["player"] = 
	#game_state["current_scene"] = current_scene_path
	
	var file = FileAccess.open(GAME_FILE, FileAccess.WRITE)
	file.store_var(game_state)
	print("Game Saved!")
	file.close()

func load_game() -> void:
	if FileAccess.file_exists(GAME_FILE):
		var file = FileAccess.open(GAME_FILE, FileAccess.READ)
		var loaded_data = file.get_var()
		
		game_state.merge(loaded_data, true) 
		print("Game Loaded!")
