extends Control

@onready var Settings = $"."
@onready var volume_slider = $BG/MarginContainer/VBoxContainer/Volume
@onready var timers: OptionButton = $BG/MarginContainer/VBoxContainer/Timers

var is_open: bool = false

#loads game settings save visuals to match
func _ready() -> void:
	sync_ui_to_settings()
	close()
	

func toggle() -> void:
	if is_open:
		close()
	else:
		open()


func open() -> void:
	visible = true
	is_open = true

func close() -> void:
	visible = false
	is_open = false

func sync_ui_to_settings() -> void:
	volume_slider.value = Savemanager.settings["master_volume"]
	timers.selected = Savemanager.settings["timer"]
	timer_selection(Savemanager.settings["timer"])
	
func master_volume(value)-> void:
	Savemanager.settings["master_volume"] = value
	AudioServer.set_bus_volume_db(0, linear_to_db(Savemanager.settings["master_volume"]))
	Savemanager.save_settings()


func timer_selection(index) -> void:
	Savemanager.settings["timer"] = index
	Savemanager.save_settings()


func _on_quit_b_pressed() -> void:
	Scenechanger.change_scene("res://src/Scenes/start.tscn","")


func _on_close_pressed() -> void:
	Settings.visible = false


func _on_tuti_b_pressed() -> void:
	if Savemanager.settings["tutoriel"] == false:
		Savemanager.settings["tutoriel"] = true
	else:
		Savemanager.settings["tutoriel"] = false
	Savemanager.save_settings()


func _on_camera_b_pressed() -> void:
	#TODO add a if no feeds detected make it unable to select
	Savemanager.settings["webcam"] = true
	Savemanager.save_settings() 
	print("Camera mode selected!")


func _on_video_b_pressed() -> void:
	#TODO Auto select this if no feed 
	Savemanager.settings["webcam"] = false
	Savemanager.save_settings()
	print("Video upload mode selected!")


func _on_select_camera_item_selected(index: int) -> void:
	Savemanager.settings["camera_name"] = index
	Savemanager.save_settings()
