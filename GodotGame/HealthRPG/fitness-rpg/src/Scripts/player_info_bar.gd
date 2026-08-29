class_name PlayerInfoBar
extends HBoxContainer

signal atb_ready()

@onready var data: BattleActor = Savemanager.party[get_index()]
@onready var _name: Label = $Name
@onready var _health: Label = $Health
@onready var _mana: Label = $SP
@onready var _anim: AnimationPlayer =$AnimationPlayer
@onready var _atb: ATBBar = $ATBbar

func _ready() -> void:
	_anim.play("RESET")
	_name.text = data.name
	_health.text = str(data.hp)
	_mana.text = str(data.mp)
	data.hp_changed.connect(_on_data_hp_changed)

func _on_data_hp_changed(hp:int,_change:int)->void:
	_health.text = str(hp)
	if hp == 0:
		modulate = Color.BLACK
		_atb.reset()
		_atb.stop()

func highlight(on:bool = true) -> void:
	var anim: String = "highlight" if on else "RESET"
	_anim.play(anim)

func reset() -> void:
	_atb.reset()

func stop()->void:
	_atb.stop()

func _on_at_bbar_filled() -> void:
	atb_ready.emit()
	#_anim.play("highlight")
