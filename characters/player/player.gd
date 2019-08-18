# Author: CoffeeStraw

extends KinematicBody

#  User Settings
export (float, 1.0, 100.0) var speed = 6
export (float, 1.0, 100.0) var acc = 3
export (float, 1.0, 100.0) var de_acc = 6
export (float, 1.0, 100.0) var gravity_mult = 3

# Variables
var _camera
var _character
var _velocity = Vector3()
var gravity = -9.81

func _ready():
	_camera    = $Target/Camera
	_character = $"."
	
	gravity *= gravity_mult
	
func _input(ev):
	if Input.is_action_just_pressed("move_run"):
		speed = 20
	elif Input.is_action_just_released("move_run"):
		speed = 6

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
	
	_velocity = _velocity.linear_interpolate(dir * speed, current_acc * delta)
	_velocity.y += delta * gravity
	_velocity = move_and_slide(_velocity, Vector3(0,1,0))
	
	# If the player is moving, rotate him
	if(dir != Vector3(0,0,0)):
		var angle = atan2(_velocity.x, _velocity.z)
		var char_rot = _character.get_rotation()
		char_rot.y = angle
		_character.set_rotation(char_rot)

func _on_SwipeDetector_swiped(gesture):
	# Calculating power (used for later calculations of speed and damage)
	var power = gesture.first_point().distance_to( gesture.last_point() )
	var max_power = Vector2(0.0, 0.0).distance_to( get_viewport().size )
	power /= max_power / 100
	
	print("Type of attack: " + str( gesture.get_direction() ) )
	print("Attack power: " + str( power ) + " / 100.0" )
	print(" ")