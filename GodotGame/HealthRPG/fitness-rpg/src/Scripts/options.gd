extends Control

@onready var inventory: Control = $Inventory
@onready var settings: Control = $"../../../../Settings"
@onready var skills: Control = $Skills
@onready var skill_list = $Skills/MarginContainer/VScrollBar/VBoxContainer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



func _on_skill_b_pressed() -> void:
	skills.toggle()
		# Clear old buttons
	for child in skill_list.get_children():
		child.queue_free()
		
	# Generate buttons for unlocked skills
	var unlocked_skills = Savemanager.game_state["skills"]
	for skill_key in unlocked_skills:
		if unlocked_skills[skill_key] == true:
			var btn = Button.new()
			btn.text = skills._get_skill_name(skill_key)
			 # When clicked, pass the skill_key to the video uploader
			btn.pressed.connect(skills._on_specific_skill_chosen.bind(skill_key))
			skill_list.add_child(btn)


func _on_items_b_pressed() -> void:
	inventory.toggle()


func _on_save_b_pressed() -> void:
	Savemanager.save_game()


func _on_options_b_pressed() -> void:
	settings.toggle()
