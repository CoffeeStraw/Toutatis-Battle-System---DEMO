extends Camera

# User settings
export var distance = 4.0
export var height = 2.0
export (float, 0.0, 1.0) var sensitivity = 0.05
export (float, 0.0, 0.999, 0.001) var smoothness = 0.9

# Script variables
const _up = Vector3(0, 1, 0)
var _yaw = 0.0
var _pitch = 0.0

func _ready():
	# Confining mouse movement in viewport
	Input.set_mouse_mode(3)
	# Moving mouse initial position to center of screen
	get_viewport().warp_mouse( get_viewport().size / 2 )
	
	# Set indipendence from character, enable physics process
	set_physics_process(true)
	set_as_toplevel(true)

func _physics_process(_delta):
	camera_move_and_rot()
	mouse_look()
	
func camera_move_and_rot():
	# Calculate movement
	var target = get_parent().get_global_transform().origin
	var pos = get_global_transform().origin
	
	var offset = pos - target
	
	offset = offset.normalized()*distance
	offset.y = height
	
	# Move and rotate camera
	pos = target + offset
	look_at_from_position(pos, target, _up)

func mouse_look():
	# Getting mouse position
	var viewport_center = get_viewport().size / 2
	var mouse_global_pos = get_viewport().get_mouse_position()
	var _mouse_pos = Vector2(
		(mouse_global_pos.x - viewport_center.x) / viewport_center.x * 100,
		(mouse_global_pos.y - viewport_center.y) / viewport_center.y * 100
	)
	
	_mouse_pos *= sensitivity
	_yaw = _yaw * smoothness + _mouse_pos.x * (1.0 - smoothness)
	_pitch = _pitch * smoothness + _mouse_pos.y * (1.0 - smoothness)
	
	# Making additional rotations
	rotate_y(deg2rad(-_yaw))
	rotate_object_local(Vector3(1,0,0), deg2rad(-_pitch))