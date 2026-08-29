class_name BattleActor extends Resource

@export var sprite_frames: SpriteFrames # <--- Holds the .tres file!
@export var should_flip: bool = false
@export var scale: float = 3.0

signal hp_changed(hp,change)
signal defeated()
signal acting()

var name: String = "Not Set"
var hp_max: int = 1
var hp: int = hp_max
var mp_max: int = 0 
var mp: int = mp_max
var strength: int = 1
var texture:Texture = null
var friendly: bool = false
var xp: int = 0 
var gold: int = 0
var level: int = 1


func _init(_hp: int = 1, _strength: int = 1, _level: int = 1, _should_flip: bool = false, _scale: float = 2.0) -> void:
	hp_max = _hp
	hp = _hp
	strength = _strength
	level = _level
	should_flip = _should_flip
	scale = _scale
	xp = _level*10
	gold = _level*5

func set_name_custom(value:String)->void:
	name = value
	
	if !friendly:
		var name_formatted:String = name.to_lower().replace(" ","_")
		texture = load("res://Assets/Enemies/"+name_formatted+".png")

func duplicate_custom() -> BattleActor:
	var dup: BattleActor = self.duplicate()
	#dup.init(hp, strength) # TODO might need this. need to test
	dup.name = name
	dup.texture = texture
	dup.should_flip = should_flip
	dup.sprite_frames = sprite_frames
	dup.scale = scale
	#Stats
	dup.hp_max = hp_max
	dup.hp = hp # Copy current HP (usually max for new enemies)
	dup.strength = strength
	dup.level = level
	dup.xp = xp
	dup.gold = gold
	return dup

func healhurt(value:int) -> void:
	var hp_start:int = hp
	var change:int = 0
	hp +=value
	hp = clamp(hp,0,hp_max)
	change = hp - hp_start
	hp_changed.emit(hp,change)
	
	if !has_hp():
		defeated.emit()

func has_hp() -> bool:
	return hp >0

func can_act() -> bool:
	return has_hp()

func act() -> void:
	acting.emit()
