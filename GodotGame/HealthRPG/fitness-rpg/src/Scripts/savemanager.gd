extends Node
# its local cus user (saved into godot app_userdata foulder)
const SETTINGS_FILE = "user://settings.dat"
const GAME_FILE = "user://savegame.dat"


var enemies:Dictionary = {
	"BeefLord": BattleActor.new(500,45,10,false,6.0),
	"Bird": BattleActor.new(200,10,5),
	"RedWolf": BattleActor.new(200,10,5),
	"BlackWolf": BattleActor.new(200,10,5),
	"Fox": BattleActor.new(200,10,5)
}

var players: Dictionary = {
	"Knight":BattleActor.new(300,75,1)
}

var party: Array = players.values()

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
	},
	"party_data": []
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
	for member in party:
		game_state["party_data"].append({
			"name": member.name,
			"hp": member.hp,
			"hp_max": member.hp_max,
			"level": member.level,
			"xp": member.xp,
			"gold": member.gold
		})
		
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
	# 3. Restore Party Stats
	var loaded_party = game_state.get("party_data", [])
	for i in range(loaded_party.size()):
		if i < party.size():
			var saved_member = loaded_party[i]
			var real_member = party[i]
			
			real_member.hp = saved_member["hp"]
			real_member.hp_max = saved_member["hp_max"]
			real_member.level = saved_member["level"]
			real_member.xp = saved_member["xp"]
			real_member.gold = saved_member["gold"]
			



func _init() -> void:
	for player in party:
		player.friendly = true
	set_keys_to_names(enemies)
	
	players["Knight"].sprite_frames = load("res://src/Assets/Player/player_animation.tres")
	
	enemies["BeefLord"].sprite_frames = load("res://src/Assets/Enemies/BeefLord.tres")
	enemies["Bird"].sprite_frames = load("res://src/Assets/Enemies/Bird.tres")
	enemies["RedWolf"].sprite_frames = load("res://src/Assets/Enemies/RedWolf.tres")
	enemies["BlackWolf"].sprite_frames = load("res://src/Assets/Enemies/BlackWolf.tres")
	enemies["Fox"].sprite_frames = load("res://src/Assets/Enemies/Fox.tres")
	
	
	for player in party:
		player.friendly = true
	set_keys_to_names(players)
	


static func set_keys_to_names(dict: Dictionary) -> void:
	var keys: Array = dict.keys()
	#print(keys)
	if dict[keys[0]] is RefCounted:
		for key in keys:
			dict[key].set_name_custom(key)
	else:
		print("Error: Dictionary must have instanced references in it. Exiting convert_keys_to_names()...")
