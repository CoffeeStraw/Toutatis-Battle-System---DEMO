# Author: CoffeeStraw

extends Camera

# Mouse settings
export (float, 0.0, 1.0) var sensitivity = 0.05
export (float, 0.0, 0.999, 0.001) var smoothness = 0.8
export var distance = 5.0
export (float, 0.01, 100.0) var no_movement_mouse_perc = 60.0 # %

# Intern variables.
var _privot
var _mouse_global_pos = Vector2(0.0, 0.0)
var _mouse_pos = Vector2(0.0, 0.0)
var _mouse_perc = Vector2()
var _yaw = 0.0
var _pitch = 0.0
var _total_pitch = 0.0

var mouse_sliding = false

func _ready():
	# Getting target, making independent from parents
	_privot = self.get_parent()
	set_as_toplevel(true)

	# Hiding mouse
	Input.set_mouse_mode(3)
	# Getting first global position of mouse
	_mouse_global_pos = get_viewport().size / 2
	get_viewport().warp_mouse(_mouse_global_pos)

	# Enabling Physics Process
	set_physics_process(true)
	set_process(false)

func _input(event):
	# Getting mouse position when mouse movement is captured
	if event is InputEventMouseMotion:
		_mouse_pos = event.relative
		_mouse_global_pos = event.position
	if event.is_action_pressed("click"):
		mouse_sliding = true
		# Change facing (HOW????)
	elif event.is_action_released("click"):
		mouse_sliding = false

func _physics_process(delta):
	# Calling updates
	_update_distance()
	_update_mouselook()
	_update_collision_detection()

func _update_distance():
	# Updating distance from target
	var t = _privot.get_global_transform().origin
	t.z -= distance
	set_translation(t)

func _update_mouselook():
	# Getting percentage distance from center of screen
	var viewport_center = get_viewport().size / 2
	_mouse_perc.x = (_mouse_global_pos.x - viewport_center.x) / viewport_center.x * 100
	_mouse_perc.y = (_mouse_global_pos.y - viewport_center.y) / viewport_center.y * 100

	var target = _privot.get_global_transform().origin
	var offset = get_global_transform().origin.distance_to(target)

	set_translation(target)
	
	# Calculating type of rotation on y axis (yaw)
	if mouse_sliding or abs(_mouse_perc.x) <= no_movement_mouse_perc:
		# Slow and one time rotation
		_mouse_pos.x *= sensitivity / 2
	else:
		# Continuos exponential rotation on the edge
		_mouse_pos.x = 100.0 - ( 100.0 - abs(_mouse_perc.x) ) / (100.0 - no_movement_mouse_perc) * 100.0
		_mouse_pos.x = pow(_mouse_pos.x / 10, 2) * sign(_mouse_perc.x)
		_mouse_pos.x *= sensitivity
		
	# Calculating type of rotation on x axis (pitch)
	if mouse_sliding or abs(_mouse_perc.y) <= no_movement_mouse_perc:
		# Slow and one time rotation
		_mouse_pos.y *= sensitivity / 2
	else:
		# Continuos exponential rotation on the edge
		_mouse_pos.y = 100.0 - ( 100.0 - abs(_mouse_perc.y) ) / (100.0 - no_movement_mouse_perc) * 100.0
		_mouse_pos.y = pow(_mouse_pos.y / 10, 2) * sign(_mouse_perc.y)
		_mouse_pos.y *= sensitivity
		
	# Updating mouse rotation over target
	_yaw = _yaw * smoothness + _mouse_pos.x * (1.0 - smoothness)
	_pitch = _pitch * smoothness + _mouse_pos.y * (1.0 - smoothness)
	_mouse_pos = Vector2(0, 0)

	_pitch = clamp(_pitch, -60 - _total_pitch, 20 - _total_pitch) # Custom pitch limit to not make camera rotate too much
	_total_pitch += _pitch
	
	# Making rotations (finally)
	rotate_y(deg2rad(-_yaw))
	rotate_object_local(Vector3(1,0,0), deg2rad(-_pitch))
	
	translate(Vector3(0.0, 0.0, offset))

func _update_collision_detection():
	# If collisions, try to move the camera to avoid the obstacle
	var space_state = get_world().get_direct_space_state()
	var obstacle = space_state.intersect_ray(_privot.get_global_transform().origin, get_global_transform().origin)
	if not obstacle.empty():
		set_translation(obstacle.position)