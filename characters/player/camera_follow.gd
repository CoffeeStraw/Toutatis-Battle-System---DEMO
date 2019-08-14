# ORIGINAL SCRIPT: Jaccomo Lorenz (https://github.com/Maujoe/godot-camera-control)
# Edits: CoffeeStraw

extends Camera

# Mouse settings
export (float, 0.0, 1.0) var sensitivity = 0.2
export (float, 0.0, 0.999, 0.001) var smoothness = 0.8
export var distance = 5.0
export (int, 0, 360) var pitch_limit = 90

# Intern variables.
var _privot
var _mouse_position = Vector2(0.0, 0.0)
var _yaw = 0.0
var _pitch = 0.0
var _total_pitch = 0.0

func _ready():
	# Getting target, making independent from parents
	_privot = self.get_parent()
	set_as_toplevel(true)
	
	# Hiding mouse
	Input.set_mouse_mode(2)
	
	# Enabling Physics Process
	set_physics_process(true)
	set_process(false)

func _input(event):
	# Getting mouse position when mouse movement is captured
	if event is InputEventMouseMotion:
		_mouse_position = event.relative

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
	# Updating mouse rotation over target
	_mouse_position *= sensitivity
	_yaw = _yaw * smoothness + _mouse_position.x * (1.0 - smoothness)
	_pitch = _pitch * smoothness + _mouse_position.y * (1.0 - smoothness)
	_mouse_position = Vector2(0, 0)

	if pitch_limit < 360:
		_pitch = clamp(_pitch, -pitch_limit - _total_pitch, pitch_limit - _total_pitch)

	_total_pitch += _pitch

	var target = _privot.get_global_transform().origin
	var offset = get_global_transform().origin.distance_to(target)

	set_translation(target)
	rotate_y(deg2rad(-_yaw))
	rotate_object_local(Vector3(1,0,0), deg2rad(-_pitch))
	translate(Vector3(0.0, 0.0, offset))
	
func _update_collision_detection():
	# If collisions, try to move the camera to avoid the obstacle
	var space_state = get_world().get_direct_space_state()
	var obstacle = space_state.intersect_ray(_privot.get_global_transform().origin, get_global_transform().origin)
	if not obstacle.empty():
		set_translation(obstacle.position)