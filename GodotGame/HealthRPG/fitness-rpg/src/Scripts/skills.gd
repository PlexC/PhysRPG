class_name Skills extends Control


@onready var skill_panel = $Container/BG
@onready var skill_list = $MarginContainer/VScrollBar/VBoxContainer

signal skill_selected(skill_key: String)

var skill_database = {
	"headbutt": preload("res://src/Assets/Skills/headbutt.tres"),
	"punch": preload("res://src/Assets/Skills/punch.tres"),
	"kick": preload("res://src/Assets/Skills/kick.tres"),
	"secret_1": preload("res://src/Assets/Skills/secret_1.tres")
}
var is_open = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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

func _get_skill_name(skill_key: String) -> String:
	return skill_database[skill_key].skill_name




func _on_specific_skill_chosen(skill_key: String) -> void:
	close()
	print("Player chose: ", skill_key)
	skill_selected.emit(skill_key)
