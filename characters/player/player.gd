# Author: CoffeeStraw

extends KinematicBody

# User Settings
export (float, 1.0, 100.0) var normal_speed = 6.0
export (float, 1.0, 100.0) var max_speed = 15.0
export (float, 1.0, 100.0) var acc = 3.0
export (float, 1.0, 100.0) var de_acc = 6.0
export (float, 1.0, 100.0) var gravity_mult = 3.0
export (float, 0.0, 100.0) var min_attack_power = 10.0
export (float, 0.0, 100.0) var max_attack_power = 100.0
export (float, 0.0, 100.0) var min_attack_duration = 0.5
export (float, 0.0, 100.0) var max_attack_duration = 3.0

# Variables
var _camera
var _character
var _anim_attacks
var _anim_tree

var _sword_collision
var _sword_trail
var _valid_attack = false

var _hud_damage
var _hud_speed
var _hud_type

var _sword_swing_audio
var _sound_thread

var _damage
var _speed = normal_speed
var _velocity = Vector3()
var _walk_run_blend = 0.0
var gravity = -9.81

signal enemy_hitten

func _ready():
	_camera       = $Target/Camera
	_character    = $ModelsAnimations
	_anim_tree    = $ModelsAnimations/Armature/AnimationTree
	_anim_tree.active = true
	
	_anim_attacks = _anim_tree['parameters/Attacks/playback']
	_sword_collision = $ModelsAnimations/Armature/BoneAttachment/Sword/Area/CollisionShape
	_sword_trail = $ModelsAnimations/Armature/BoneAttachment/Sword/Trail/ImmediateGeometry
	#warning-ignore:return_value_discarded
	$ModelsAnimations/Armature/BoneAttachment/Sword/Area.connect("body_entered", self, "_on_Enemy_Hitten")
	
	_sword_swing_audio = $SwordSwingAudio
	
	_hud_damage = $HUD/Panel/DamageValue
	_hud_speed  = $HUD/Panel/SpeedValue
	_hud_type   = $HUD/Panel/TypeValue
	
	gravity *= gravity_mult
	
	# Connecting enemy
	get_parent().get_node("Enemy_Ogre").connect("player_hitten", self, "_on_hit")
	
func _input(ev):
	if Input.is_action_just_pressed("move_run"):
		_speed = max_speed
	elif Input.is_action_just_released("move_run"):
		_speed = normal_speed
	elif ev is InputEventMouseButton:
		if (ev.is_pressed() and ev.button_index == BUTTON_LEFT):
			$MouseSystem/MouseTrail.is_enabled = true
		else:
			$MouseSystem/MouseTrail.is_enabled = false

func _physics_process(delta):
	# PLAYER MOVEMENT
	var dir = Vector3()
	var cam_xform = _camera.get_global_transform()
	
	# Taking the direction where player intend to walk to
	if Input.is_action_pressed("move_fw"):
		dir -= cam_xform.basis[2]
	if Input.is_action_pressed("move_bw"):
		dir += cam_xform.basis[2]
	if Input.is_action_pressed("move_l"):
		dir -= cam_xform.basis[0]
	if Input.is_action_pressed("move_r"):
		dir += cam_xform.basis[0]
	
	dir.y = 0
	dir = dir.normalized()
	
	# Checking if Player is accelerating or de-accelerating,
	# by calculating dot product between current direction of velocity and old one
	var hv = _velocity
	hv.y = 0
	
	# If vectors are facing the same direction
	var current_acc = de_acc
	if (dir.dot(hv) > 0):
		current_acc = acc
		
	hv = hv.linear_interpolate(dir * _speed, current_acc * delta)
	
	_velocity.x = hv.x
	_velocity.y += delta * gravity
	_velocity.z = hv.z
	_velocity = move_and_slide(_velocity, Vector3(0,1,0), true) # Doesn't slide on slopes
	
	# If the player is moving, rotate him
	if(dir != Vector3(0,0,0)):
		# Rotating basing on global rotation
		var angle = atan2(_velocity.x, _velocity.z) - _character.global_transform.basis.get_euler().y
		_character.global_rotate(Vector3(0,1,0), angle)
	
	# Animation walk/run
	var speed_blend = hv.length() * 2 / max_speed
	_anim_tree.set("parameters/Idle_Walk/blend_amount", speed_blend)
	_anim_tree.set("parameters/Idle_Run/blend_amount", speed_blend)
	
	if _speed == normal_speed:
		_walk_run_blend = clamp(_walk_run_blend-0.1, 0.0, 1.0)
	else:
		_walk_run_blend = clamp(_walk_run_blend+0.1, 0.0, 1.0)

	_anim_tree.set("parameters/Walk_Run/blend_amount", _walk_run_blend)
	
	# Improvable: Checking if some attack animation is running, then activate trail for sword
	if _anim_tree.get("parameters/AttackShot/active") and not _sword_trail.trailEnabled:
		_valid_attack = true
		_sword_trail.trailEnabled = true
	elif not _anim_tree.get("parameters/AttackShot/active"):
		_valid_attack = false
		_sword_trail.trailEnabled = false
	
func _on_SwipeDetector_swiped(gesture):
	# Check if some animation is already playing, if true then ignore the swipe
	if _anim_tree.get("parameters/AttackShot/active"):
		return
	
	# Saving animation name
	var anim_name = "attack_" + str( gesture.get_direction() )
	
	# Calculating power of the attack (also used later for calculation of animation speed)
	_damage = gesture.first_point().distance_to( gesture.last_point() )
	_damage /= Vector2(0.0, 0.0).distance_to( get_viewport().size )
	var _damage_percent = _damage
	_damage = min_attack_power + _damage * (max_attack_power - min_attack_power)
	
	# Calculating a factor to normalize all attack animations duration
	var _attack_speed = $ModelsAnimations/Armature/AnimationPlayer.get_animation(anim_name).get_length()
	_attack_speed /= (min_attack_duration + (max_attack_duration - min_attack_duration) * _damage_percent)
	
	# Activate sound after some delay to match animation
	var _animation_length = $ModelsAnimations/Armature/AnimationPlayer.get_animation(anim_name).get_length() / _attack_speed
	_sound_thread = Thread.new()
	_sound_thread.start(self, "play_sound", _animation_length)
	
	# Enabling attack animation
	_anim_attacks.start(anim_name)
	_anim_tree.set("parameters/AttackShot/active", true)
	_anim_tree.set("parameters/AttackSpeed/scale", _attack_speed)
	
	# Setting texts' HUD
	_hud_damage.set_text(str(int(_damage)))
	_hud_speed.set_text(str(float(_animation_length)))
	_hud_type.set_text(str(gesture.get_direction()))

func play_sound(animation_length):
	# Note that 0.41551 is the length of the sound
	yield(get_tree().create_timer(animation_length/2.2), "timeout")
	_sword_swing_audio.set_pitch_scale(0.41551 / animation_length * 1.6) # 1.6 is a fix to let the sound ends faster
	_sword_swing_audio.play()
	_sound_thread.wait_to_finish()

func _on_hit(damage):
	var _current_health = int($HUD/LifeBar/Control/Current.text)
	_current_health -= int(damage)
	
	if _current_health > 0:
		$HUD/LifeBar/Control/Current.text = str(_current_health)
		$HUD/LifeBar/Bar.value = _current_health
	else:
		$HUD/LifeBar/Control/Current.text = "0"
		$HUD/LifeBar/Bar.value = 0
		hide()

func _on_Enemy_Hitten(body):
	if _valid_attack:
		_valid_attack = false
		emit_signal("enemy_hitten", _damage)