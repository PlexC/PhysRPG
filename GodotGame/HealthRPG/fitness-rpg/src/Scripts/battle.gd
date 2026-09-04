extends Control

#_down_cursor.show()
		#_down_cursor.global_position = _enemies_menu.get_children()[index].global_position - Vector2(-35,80)

enum States{
	OPTIONS,
	TARGETS,
	VICTORY,
	GAMEOVER,
	BETWEEN,
}

enum Actions{
	FIGHT,
	ITEMS,
	MISS,
	SKIP
}

enum{
	ACTOR,
	TARGET,
	ACTION,
}

var state: States =States.OPTIONS
var player_atb_queue: Array = []
var event_queue: Array = []
var event_running:bool = false
var action: Actions = Actions.FIGHT
var miss: Actions = Actions.MISS
var player: BattleActor = null
var pending_target: BattleActor = null
var current_skill_name: String = ""

@onready var _options: Control = $Options
#@onready var _options_menu: Control = $Options/Menu
@onready var _enemies_menu: Control = $Enemies
@onready var _players_menu: Control = $Player
@onready var _players_infos: Array = $PlayerInfoBar.get_children()
@onready var http_request: HTTPRequest = $"HTTPRequest"
@onready var video_picker: FileDialog = $"VideoPicker"
@onready var reward: CanvasLayer = $Reward
@onready var skills: Skills = $Options/Skills
@onready var _down_cursor: TextureRect = $DownCursor
@onready var inventory_ui: Control = $"../../../Inventory/"




func _ready() -> void:
	#Musicmanager.play("res://Utility/battle.mp3")
	#_options.hide()
	Savemanager.load_game()
	video_picker.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	video_picker.access = FileDialog.ACCESS_FILESYSTEM
	_down_cursor.hide()
	_down_cursor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if skills:
		if not skills.skill_selected.is_connected(_on_skill_selected):
			skills.skill_selected.connect(_on_skill_selected)
			
	Scenechanger.pending_enemy_data = [
				Savemanager.enemies.values().pick_random().duplicate_custom(),
				Savemanager.enemies.values().pick_random().duplicate_custom(),
				Savemanager.enemies.values().pick_random().duplicate_custom()
				]
	var player_buttons = _players_menu.get_children()
	var enemy_buttons = _enemies_menu.get_children()
	##GRAB DATA 
	var battle_squad = Scenechanger.pending_enemy_data
	#
	## Safety Fallback (Test Mode)
	#if battle_squad.is_empty():
		#battle_squad = [Data.enemies["BeefLord"].duplicate_custom()]
	inventory_ui.item_used.connect(_on_inventory_item_used)
	for i in range(enemy_buttons.size()):
		if i < battle_squad.size():
			var enemy_data = battle_squad[i]
			enemy_buttons[i].set_data(enemy_data)
			# Connect Signals
			enemy_buttons[i].atb_ready.connect(_on_enemy_atb_ready.bind(enemy_data))
			enemy_data.defeated.connect(_on_battle_actor_defeated.bind(enemy_data))
			if not enemy_buttons[i].pressed.is_connected(_on_enemeies_button_pressed):
				enemy_buttons[i].pressed.connect(_on_enemeies_button_pressed.bind(enemy_buttons[i], i))
			
			# Ensure button is visible
			enemy_buttons[i].show()
			enemy_buttons[i].reset()
			enemy_buttons[i].focus_mode = Control.FOCUS_ALL 
			# Make the cursor follow both keyboard focus AND mouse hovers
			enemy_buttons[i].focus_entered.connect(_on_enemy_targeted.bind(enemy_buttons[i]))
			enemy_buttons[i].mouse_entered.connect(enemy_buttons[i].grab_focus)
			
		else:
			# Hide unused buttons (e.g. if only 1 boss)
			enemy_buttons[i].hide()
	
	#connect to player and enemies
	var data: BattleActor = null
	for player_info in _players_infos:
		data = player_info.data
		player_info.atb_ready.connect(_on_player_atb_ready.bind(player_info))
		data.defeated.connect(_on_battle_actor_defeated.bind(data))
		
	for enemy_button in _enemies_menu.get_children():
		data = enemy_button.data
		if data == null:
			continue
		if not enemy_button.atb_ready.is_connected(_on_enemy_atb_ready):
			enemy_button.atb_ready.connect(_on_enemy_atb_ready.bind(enemy_button.data))
		if not data.defeated.is_connected(_on_battle_actor_defeated):
			data.defeated.connect(_on_battle_actor_defeated.bind(data))
	
#func _on_Option_button_focused(button: BaseButton) -> void:

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		match state:
			States.OPTIONS:
				pass
			States.TARGETS:
				state = States.OPTIONS
				#_options_menu.button_focus()
	if event.is_action_pressed("debug_win"): #mapped input
		#if SceneManager.is_boss_battle:
			#return
		force_victory()
	if event.is_action_pressed("skip"):
		if pending_target:
			print("Playtest Skip: Executing weak attack!")
			add_event([player, pending_target, Actions.SKIP])
			advance_atb_queue()


func _on_enemy_targeted(enemy_btn: EnemyButton) -> void:
	if state == States.TARGETS:
		_down_cursor.show()
		_down_cursor.global_position = enemy_btn.global_position - Vector2(-35, 80)


func force_victory() -> void:
	print("DEBUG: Auto-Win Triggered")
	state = States.VICTORY
	end()
#func add_actor_to_atb_queue(actor: TextureButton) -> void:
	#if player_atb_queue.is_empty():
		#actor.highlight()

func find_valid_target(target: BattleActor)->BattleActor:
	if target.has_hp():
		return target
		
	var target_buttons: Array = []
	var target_is_friendly:bool = target.friendly
	if target_is_friendly:
		target_buttons = _players_menu.get_children()
	else:
		target_buttons = _enemies_menu.get_children()
	target = null
	target_buttons.shuffle()
	for i in range(target_buttons.size()):
		var button: BattleActorButton = target_buttons[i]
		var data: BattleActor = button.data
		if data.has_hp():
			target = data
			break
	if target == null:
		state = States.GAMEOVER if target_is_friendly else States.VICTORY
	return target

func end() -> void:
	#end of battle
	
		event_queue.clear()
		player_atb_queue.clear()
		#_options.hide()
		_down_cursor.hide()
		await get_tree().create_timer(0.2).timeout
		#await get_tree().physics_frame
		for player_info in _players_infos:
			player_info.highlight(false)
			player_info.reset()
			player_info.stop()
		await get_tree().create_timer(1.0).timeout
		match state:
			States.VICTORY:
			# Give Rewards (Fake for now)
				#for member in Savemanager.party:
						#member.hp = member.hp_max
				print("Victory! Gained XP and Gold and a Potion.")
				for enemy in _enemies_menu.get_children():
					enemy.hide()
				await reward.get_reward()
				Savemanager.save_game()
				state = States.BETWEEN
				Scenechanger.is_walking = true
				for player_btn in _players_menu.get_children():
					if player_btn.has_method("_on_walking"):
						player_btn._on_walking()
				await get_tree().create_timer(2.0).timeout
				Scenechanger.is_walking = false
				#get new enemies
				var new_squad = [
				Savemanager.enemies.values().pick_random().duplicate_custom(),
				Savemanager.enemies.values().pick_random().duplicate_custom(),
				Savemanager.enemies.values().pick_random().duplicate_custom()
				]
				Scenechanger.pending_enemy_data = new_squad
				get_tree().reload_current_scene()


			States.GAMEOVER:
				#normal
				for member in Savemanager.party:
					member.hp = member.hp_max
				print("Defeat... Restarting Battle.")
				get_tree().reload_current_scene()

func advance_atb_queue(remove_front:bool = true) -> void:
	if state >= States.VICTORY:
		return
		
	state = States.OPTIONS
	
	if player_atb_queue.is_empty():
		return 
	
	if remove_front:
		var current_player_info_bar: PlayerInfoBar = player_atb_queue.pop_front()
		current_player_info_bar.highlight(false)
	
	if player_atb_queue.is_empty():
		_down_cursor.hide()
		get_viewport().gui_release_focus()
	else:
		var next_player_info_bar: PlayerInfoBar = player_atb_queue.front()
		var index:int = next_player_info_bar.get_index()
		next_player_info_bar.highlight()
		player = Savemanager.party[index]
		_down_cursor.hide()
		#_options.show()
		#_options_menu.button_focus(0)

func wait(duration:float)->void:
	await get_tree().create_timer(duration).timeout

func run_event()->void:
	if event_queue.is_empty():
		event_running = false
		return
	event_running = true
	await get_tree().create_timer(0.2).timeout
	if state >= States.VICTORY:
		return

	var event: Array = event_queue.pop_front()
	var actor: BattleActor = event[ACTOR]
	var target: BattleActor = event[TARGET]
	
	#skip event if actor cant act(dead)
	if !actor.can_act():
		run_event()
	
	#ensure valid target
	var target_is_friendly:bool = Savemanager.party.has(target)
	target = find_valid_target(target)
	
	if target == null:
		end()
		return
	
	#preform action
	actor.act()
	await get_tree().create_timer(0.2).timeout
	match event[ACTION]:
		Actions.FIGHT:
			target.healhurt(-actor.strength)
		Actions.MISS:
			target.miss()
		Actions.SKIP:
			target.healhurt(-int(actor.strength / 3.0))
		_:
			pass
	await get_tree().create_timer(0.5).timeout
	if actor.friendly:
		_players_infos[Savemanager.party.find(actor)].reset()
	else:
		var enemies: Array = _enemies_menu.get_children()
		for enemy in enemies:
			if not "data" in enemy:
				continue
			if enemy.data == actor:
				enemy.reset()
				break
	run_event()

func add_event(event:Array)->void:
	event_queue.append(event)
	if !event_running:
		run_event()

func _on_menu_button_pressed(button: BaseButton, index: int) -> void:
	match button.text:
		"Skill":
			if _enemies_menu.buttons.is_empty():
				return
			action = Actions.FIGHT
			state = States.TARGETS
			_enemies_menu.button_focus()
		"Items":
			pass

func _on_player_atb_ready(player_info: PlayerInfoBar) -> void:
	player_atb_queue.append(player_info)
	if player_atb_queue.size() == 1:
		advance_atb_queue(false)
	#if player_atb_queue.is_empty():
		#player = Data.party[player_info.get_index()]
		#player_info.highlight()
		#_options.show()
		#_options_menu.button_focus(0)

func _on_enemy_atb_ready(enemy: BattleActor) -> void:
	var target: BattleActor = Savemanager.party.pick_random()
	add_event([enemy,target,Actions.FIGHT])
	

func _on_enemeies_button_pressed(button: EnemyButton,index: int) -> void:
	#TODO store event here
	if state != States.TARGETS:
		return
	video_picker.popup_centered(Vector2(600, 400))
	pending_target = button.data
	
	#add_event([player, pending_target, action])
	#advance_atb_queue()

func _on_video_picker_file_selected(path: String):
	print("Uploading video for AI grading...")
	# 1. Read the video file from drive
	var video_bytes = FileAccess.get_file_as_bytes(path)
	# 2. Format the header for raw data
	var headers = ["Content-Type: application/octet-stream"] 
	# 3. Send to Python (Change 'squat' to a dynamic skill name later)
	var url = "http://127.0.0.1:8000/evaluate_skill/" + current_skill_name
	http_request.request_raw(url, headers, HTTPClient.METHOD_POST, video_bytes)

func _on_http_request_request_completed(result, response_code, headers, body):
	# 1. Safety Buffer: Server offline or rejected the request
	if response_code != 200:
		print("Server error (", response_code, ")! Fallback to weak attack.")
		add_event([player, pending_target, Actions.SKIP])
		advance_atb_queue()
		return
		
	# 2. Parse JSON
	var json = JSON.new()
	var parse_error = json.parse(body.get_string_from_utf8())
	
	# Safety Buffer: Backend sent broken data
	if parse_error != OK:
		print("Broken server response! Fallback to weak attack.")
		add_event([player, pending_target, Actions.SKIP])
		advance_atb_queue()
		return
		
	# 3. Normal AI Grading
	var response = json.get_data()
	# Using .get() prevents crashes if the dictionary is missing these keys
	if response.get("success", false) == true and response.get("score", 0) >= 70:
		print("Good form! Attack hits!")
		add_event([player, pending_target, Actions.FIGHT])
	else:
		print("Bad form! Attack missed!")
		add_event([player, pending_target, Actions.MISS])
		
	advance_atb_queue()



func _on_skill_selected(skill_key: String) -> void:
	var enemies = _enemies_menu.get_children()
	if enemies.is_empty():
		return
	# 1. Save the skill name for the video upload
	current_skill_name = skill_key 
	# 2. Change state to TARGETS so clicking an enemy opens the camera
	action = Actions.FIGHT
	state = States.TARGETS
	print("Skill : ", current_skill_name, ". Now pick an enemy!")
	for enemy in enemies:
		if enemy.visible:
			enemy.grab_focus()
			break

func _on_players_button_pressed(button: PlayerButton,index: int) -> void:
	#TODO store event here
	var target: BattleActor = button.data
	add_event([player, target, action])
	advance_atb_queue()

func _on_battle_actor_defeated(data: BattleActor) -> void:
	if !find_valid_target(data):
		await get_tree().physics_frame
		end()
	
	var player_index:int = Savemanager.party.find(data)
	if player_index != -1:
		var player_info: PlayerInfoBar =  _players_infos[player_index]
		player_atb_queue.erase(player_info)

func _on_inventory_item_used() -> void:
	print("Item used! Turn over.")
	_players_infos[Savemanager.party.find(player)].reset()
	advance_atb_queue()
