extends KinematicBody

# CONSTANT (Configuration)
const SPEED = 6
const ACC = 3
const DE_ACC = 6
const GRAVITY = -9.81

# Variables
var camera
var character
var velocity = Vector3()

func _ready():
	camera    = get_node("Target/Camera")
	character = get_node(".")

func _physics_process(delta):
	
	# PLAYER MOVEMENT
	var dir = Vector3()
	var cam_xform = camera.get_global_transform()
	
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
	var hv = velocity
	hv.y = 0
	
	# If vectors are facing the same direction
	var accel = DE_ACC
	if (dir.dot(hv) > 0):
		accel = ACC
	
	velocity = velocity.linear_interpolate(dir * SPEED, accel * delta)
	velocity.y += delta * GRAVITY
	velocity = move_and_slide(velocity, Vector3(0,1,0))
	
	# If the player is moving, rotate him
	if(dir != Vector3(0,0,0)):
		var angle = atan2(velocity.x, velocity.z)
		var char_rot = character.get_rotation()
		char_rot.y = angle
		character.set_rotation(char_rot)