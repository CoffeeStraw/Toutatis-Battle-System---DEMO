# Author: CoffeeStraw

extends KinematicBody

#  User Settings
export (float, 1.0, 100.0) var normal_speed = 6
export (float, 1.0, 100.0) var max_speed = 15
export (float, 1.0, 100.0) var acc = 3
export (float, 1.0, 100.0) var de_acc = 6
export (float, 1.0, 100.0) var gravity_mult = 3

# Variables
var _camera
var _character
var _anim_attacks
var _anim_tree

var _sword_collision

var _hud_damage
var _hud_speed
var _hud_type

var _speed = normal_speed
var _velocity = Vector3()
var _walk_run_blend = 0.0
var gravity = -9.81

func _ready():
	_camera       = $"Target/Camera"
	_character    = $"Character Models and Stuff"
	_anim_tree    = $"Character Models and Stuff/Armature/AnimationTree"
	_anim_tree.active = true
	_anim_attacks = _anim_tree['parameters/Attacks/playback']
	_sword_collision = $"Character Models and Stuff/Armature/BoneAttachment/Sword/StaticBody/CollisionShape"
	
	_hud_damage = $"HUD/Panel/DamageValue"
	_hud_speed  = $"HUD/Panel/SpeedValue"
	_hud_type   = $"HUD/Panel/TypeValue"
	
	gravity *= gravity_mult
	
func _input(ev):
	if Input.is_action_just_pressed("move_run"):
		_speed = max_speed
	elif Input.is_action_just_released("move_run"):
		_speed = normal_speed
	elif ev is InputEventMouseButton:
		if (ev.is_pressed() and ev.button_index == BUTTON_LEFT):
			$CustomCursor/MouseTrail.emitting = true
		else:
			$CustomCursor/MouseTrail.emitting = false

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
	_velocity = move_and_slide(_velocity, Vector3(0,1,0))
	
	# If the player is moving, rotate him
	if(dir != Vector3(0,0,0)):
		var angle = atan2(_velocity.x, _velocity.z)
		var char_rot = _character.get_rotation()
		char_rot.y = angle
		_character.set_rotation(char_rot)
		
	var speed_blend = hv.length() * 2 / max_speed
	_anim_tree.set("parameters/Idle_Walk/blend_amount", speed_blend)
	_anim_tree.set("parameters/Idle_Run/blend_amount", speed_blend)
	
	if _speed == normal_speed:
		_walk_run_blend = clamp(_walk_run_blend-0.1, 0.0, 1.0)
	else:
		_walk_run_blend = clamp(_walk_run_blend+0.1, 0.0, 1.0)

	_anim_tree.set("parameters/Walk_Run/blend_amount", _walk_run_blend)

func _on_SwipeDetector_swiped(gesture):
	# Saving animation name
	var anim_name = "attack_" + str( gesture.get_direction() )
	
	# Calculating power (used for later calculations of speed and damage)
	var power = gesture.first_point().distance_to( gesture.last_point() )
	var max_power = Vector2(0.0, 0.0).distance_to( get_viewport().size )
	power /= max_power / 100
	
	# Calculating attack speed, normalizing all attack animations duration
	var anim_speed_fix = 0.0
	match anim_name:
		"attack_left":
			anim_speed_fix = 0.0
		"attack_right":
			anim_speed_fix = -0.2
		"attack_down":
			anim_speed_fix = -1.2
	
	var attack_speed = 1 + anim_speed_fix + (100.0-power) * 3 / 100
	
	# Enabling attack animation
	_anim_attacks.start(anim_name)
	_anim_tree.set("parameters/AttackShot/active", true)
	_anim_tree.set("parameters/AttackSpeed/scale", attack_speed)
	
	# Setitng HUD
	_hud_damage.set_text(str(int(power)))
	_hud_speed.set_text(str(float(attack_speed)))
	_hud_type.set_text(str(gesture.get_direction()))