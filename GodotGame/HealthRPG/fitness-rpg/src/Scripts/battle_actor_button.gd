class_name BattleActorButton extends TextureButton

const HIT_TEXT:PackedScene = preload("res://src/Scenes/hit_text.tscn")

const RECOIL: int = 10

var data: BattleActor = null
var tween: Tween = null

@onready var start_pos: Vector2 = position
@onready var recoil_dir: int = 1 if global_position.x > Globals.GAME_SIZE.x*0.5 else - 1 

@onready var _sprite: AnimatedSprite2D = $Visuals/Sprite
@onready var _visuals: Node2D = $Visuals
@onready var _anim_player: AnimationPlayer = $AnimationPlayer

func set_data(_data: BattleActor) ->void:
	data = _data
	if data.sprite_frames:
			_sprite.sprite_frames = data.sprite_frames
			_sprite.play("idle") # Auto-plays the idle animation from the file
			# 2. AUTO-SIZE THE BUTTON
			# get the size of the first frame
			var texture = data.sprite_frames.get_frame_texture("idle", 0)
			if texture:
				custom_minimum_size = texture.get_size() * data.scale
				size = custom_minimum_size
			
	#elif data.texture:
		#_sprite.texture = data.texture
	elif data.texture:
		# AnimatedSprite2D cant take a simple texture.
		#  temp "SpriteFrames" container for it.
		var frames = SpriteFrames.new()
		frames.add_animation("idle")
		frames.set_animation_loop("idle", true)
		frames.add_frame("idle", data.texture)
		
		_sprite.sprite_frames = frames
		_sprite.play("idle")
		
		# Auto-size logic for the single texture
		custom_minimum_size = data.texture.get_size() * data.scale
		size = custom_minimum_size
		
	_visuals.position = size / 2
	_sprite.position = Vector2.ZERO
	
	var final_scale_x = data.scale
	var need_flip = data.should_flip
	#if not data.friendly:
		#need_flip = not need_flip
		# Scale X of -1 flips the container AND inverts movement!
		# +50 movement becomes -50 movement automatically.
	if need_flip:
		final_scale_x = -data.scale
	_visuals.scale = Vector2(final_scale_x, data.scale)
		
	if not data.hp_changed.is_connected(_on_data_hp_changed):
		data.hp_changed.connect(_on_data_hp_changed)
		
	if not data.defeated.is_connected(_on_data_defeated):
		data.defeated.connect(_on_data_defeated)
		
	if not data.acting.is_connected(_on_data_acting):
		data.acting.connect(_on_data_acting)
		
	play_anim("idle")
	var atb = get_node_or_null("ATBbar")
	if atb:
		# 1. Center horizontally: (Button Width / 2) - (Bar Width / 2)
		var center_x = (size.x / 2) - (atb.size.x / 2)
		# 2. Place above vertically: Top of button (0) minus Bar Height minus Padding
		var top_y = -atb.size.y - 20 
		atb.position = Vector2(center_x, top_y)

func recoil()-> void:
	if tween:
		tween.kill()
	tween = create_tween()
	#start
	tween.tween_property(self, "position:x",start_pos.x+(RECOIL*recoil_dir), 0.25).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "self_modulate",Color.CRIMSON, 0.25).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	#end
	tween.tween_property(self, "position:x",start_pos.x, 0.1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "self_modulate",Color.WHITE, 0.25).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func action_slide() ->void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "position:x",start_pos.x+(RECOIL*recoil_dir*-1), 0.25).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:x",start_pos.x, 0.1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)

func _on_data_hp_changed(hp:int,change:int)->void:
	var hit_text:Label = HIT_TEXT.instantiate()
	hit_text.text = str(abs(change)) if change != 0 else "MISS"
	add_child(hit_text)
	hit_text.position = Vector2(size.x*0.15,-10)
	
	if sign(change) == -1:
		play_anim("hit")
		recoil()
	

func _on_data_defeated()->void:
	play_anim("dead")
	
	if _sprite.sprite_frames.has_animation("dead"):
		await _sprite.animation_finished
		_sprite.pause()
		_sprite.frame = _sprite.sprite_frames.get_frame_count("dead") - 1
	
	if self is PlayerButton:
		modulate = Color.BLACK
	# Keep existing logic for enemies disappearing
	elif self is EnemyButton:
		await get_tree().create_timer(1.0).timeout
		queue_free()
	
	
func _on_data_acting()->void:
	play_anim("attack")
	action_slide()

func play_anim(anim_name: String) -> void:
	# A. Check if the SPRITE (Visuals) has this animation (e.g. "attack", "idle")
	if _sprite.sprite_frames.has_animation(anim_name):
		_sprite.play(anim_name)
		
		# If it's an attack, wait for it to finish then go back to idle
		if anim_name == "attack" or anim_name == "hit":
			await _sprite.animation_finished
			if _sprite.sprite_frames.has_animation("idle"):
				_sprite.play("idle")
			
	# B. ALSO check the AnimationPlayer (for Effects like "hit" flash or recoil)
	if _anim_player.has_animation(anim_name):
		_anim_player.play(anim_name)

func _on_walking()->void:
	if Scenechanger.is_walking == true:
		play_anim("walk")
		await _sprite.animation_finished
