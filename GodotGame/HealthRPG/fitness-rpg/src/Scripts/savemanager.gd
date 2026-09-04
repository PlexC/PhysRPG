extends Node
# its local cus user (saved into godot app_userdata foulder)
const SETTINGS_FILE = "user://settings.dat"
const GAME_FILE = "user://savegame.dat"

@onready var live_inventory: Inventory = preload("res://src/Inv/player_inv.tres")

var enemies:Dictionary = {
	"Bird": BattleActor.new(50,5,1,true,1.4),
	"RedWolf": BattleActor.new(90,7,1,true,1.4),
	"BlackWolf": BattleActor.new(90,7,1,true,1.4),
	"Fox": BattleActor.new(70,10,2,true,1.4)
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
	if not game_state.has("inventory"):
		game_state["inventory"] = {}
	if not game_state.has("party_data"):
		game_state["party_data"] = []
	for member in party:
		game_state["party_data"].append({
			"name": member.name,
			"hp": member.hp,
			"hp_max": member.hp_max,
			"level": member.level,
			"xp": member.xp,
			"gold": member.gold
		})
	#inv save
	for i in range(9):
		var slot_key = "slot" + str(i + 1)
		var inv_slot = live_inventory.slots[i]
		
		if inv_slot != null and inv_slot.item != null:
			game_state["inventory"][slot_key] = [inv_slot.item.resource_path, inv_slot.amount]
		else:
			game_state["inventory"][slot_key] = ["", 0]
	
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
			party[i].hp = loaded_party[i].get("hp", party[i].hp_max)
			party[i].hp_max = loaded_party[i].get("hp_max", party[i].hp_max)
			party[i].level = loaded_party[i].get("level", 1)
			party[i].xp = loaded_party[i].get("xp", 0)
			party[i].gold = loaded_party[i].get("gold", 0)


	var saved_inv = game_state.get("inventory", {}) 
	for i in range(9):
		var slot_key = "slot" + str(i + 1)
		var saved_item_data = saved_inv.get(slot_key, ["", 0]) 
		var item_path = saved_item_data[0] 
		var item_amount = saved_item_data[1] 
		
		while live_inventory.slots.size() <= i:
			live_inventory.slots.append(null)

		var inv_slot = live_inventory.slots[i]
		if inv_slot == null:
			inv_slot = InvSlot.new()
			live_inventory.slots[i] = inv_slot

		if item_path != "":
			inv_slot.item = load(item_path)
			inv_slot.amount = item_amount
		else:
			inv_slot.item = null
			inv_slot.amount = 0
	live_inventory.update.emit()



func _init() -> void:
	for player in party:
		player.friendly = true
	set_keys_to_names(enemies)
	
	players["Knight"].sprite_frames = load("res://src/Assets/Player/player_animation.tres")
	
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
