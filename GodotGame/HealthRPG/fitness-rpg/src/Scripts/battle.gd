extends Control

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
var player: BattleActor = null


@onready var _options: Control = $Options
#@onready var _options_menu: Control = $Options/Menu
@onready var _enemies_menu: Control = $Enemies
@onready var _players_menu: Control = $Player
@onready var _players_infos: Array = $PlayerInfoBar.get_children()


func _ready() -> void:
	#Musicmanager.play("res://Utility/battle.mp3"
	#_options.hide()
	
	var player_buttons = _players_menu.get_children()
	var enemy_buttons = _enemies_menu.get_children()
	##GRAB DATA 
	var battle_squad = Scenechanger.pending_enemy_data
	#
	## Safety Fallback (Test Mode)
	#if battle_squad.is_empty():
		#battle_squad = [Data.enemies["BeefLord"].duplicate_custom()]
	
	for i in range(enemy_buttons.size()):
		if i < battle_squad.size():
			var enemy_data = battle_squad[i]
			enemy_buttons[i].set_data(enemy_data)
			# Connect Signals
			enemy_buttons[i].atb_ready.connect(_on_enemy_atb_ready.bind(enemy_data))
			enemy_data.defeated.connect(_on_battle_actor_defeated.bind(enemy_data))
			
			# Ensure button is visible
			enemy_buttons[i].show()
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
		_options.hide()
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
				for member in Savemanager.party:
						member.hp = member.hp_max
						print("Victory! Gained XP and Gold.")
				
			
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
		get_viewport().gui_release_focus()
	else:
		var next_player_info_bar: PlayerInfoBar = player_atb_queue.front()
		var index:int = next_player_info_bar.get_index()
		next_player_info_bar.highlight()
		player = Savemanager.party[index]
		_options.show()
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
	var target: BattleActor = button.data
	add_event([player, target, action])
	advance_atb_queue()


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
