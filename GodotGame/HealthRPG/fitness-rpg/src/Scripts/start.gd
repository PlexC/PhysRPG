extends Control

@onready var settings: Control = $Settings
@onready var textbox: Textbox = $Textbox
@onready var start: TextureButton = $BG/MarginContainer/HBoxContainer/Start
@onready var button_container: HBoxContainer = $BG/MarginContainer/HBoxContainer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start.grab_focus()
	settings.visible = false

#for testing focus
func _process(_delta: float) -> void:
	pass

func _on_start_pressed() -> void:
	Scenechanger.change_scene("res://src/Scenes/main.tscn","")

func _on_load_pressed() -> void:
	release_focus()


func _on_quit_pressed() -> void:
	get_tree().quit()
	


func _on_credit_pressed() -> void:
	button_container.process_mode = Node.PROCESS_MODE_DISABLED
	textbox.start("System", get_Credits())
	await textbox.finished
	button_container.process_mode = Node.PROCESS_MODE_INHERIT


func _on_settings_b_pressed() -> void:
	release_focus()
	settings.visible = true
	settings.volume_slider.grab_focus()
	


func get_Credits() -> Array:
	var file_path = "res://src/credits.txt"

	if not FileAccess.file_exists(file_path):
		print("cannot find file!")
		return ["Error: Credits file not found."] 
	else:
		var full_text = FileAccess.get_file_as_string(file_path)
		return full_text.split("\n")
