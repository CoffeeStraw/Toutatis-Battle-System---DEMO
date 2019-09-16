extends KinematicBody

var chasing = false
var target = null
export (float) var speed = 3
export (float, 1.0, 100.0) var acc = 3
export (float, 1.0, 100.0) var de_acc = 6
export (float, 0.0, 100.0) var attack_distance = 4.5
export (float, 0.0, 100.0) var spawn_tolerance_distance = 1.0
export (int) var damage = 20

var _gravity = 9.81*10
var _velocity = Vector3()
var _anim_tree
var _spawn_point
var _attack_shot

signal player_hitten

# Called when the node enters the scene tree for the first time.
func _ready():
	_anim_tree = $Models_Animations/Armature/AnimationTree
	_spawn_point = get_global_transform()
	$Models_Animations/Armature/BoneAttachment/Club/Area.connect("body_entered", self, "_on_Club_Hit")
	
	# Connecting player
	get_parent().get_node("Player").connect("enemy_hitten", self, "_on_hit") 

func _process(delta):
	if chasing:
		# Chase the player
		var _dir = target.get_global_transform().origin - get_global_transform().origin

		if target.get_global_transform().origin.distance_to(get_global_transform().origin) < attack_distance and not _anim_tree.get("parameters/AttackShot/active"):
			_attack_shot = false
			var delta_x = target.get_global_transform().origin.x - get_global_transform().origin.x
			var delta_z = target.get_global_transform().origin.z - get_global_transform().origin.z
			var angle = atan2(delta_x, delta_z) - global_transform.basis.get_euler().y
			global_rotate(Vector3(0,1,0), angle)
			_anim_tree.set("parameters/AttackShot/active", true)
			_dir = Vector3()
			$Club_Smash.play()
		elif _anim_tree.get("parameters/AttackShot/active"):
			_dir = Vector3()
			

		_dir.y = 0
		_dir = _dir.normalized()
		
		var hv = _velocity
		hv.y = 0
		
		# If vectors are facing the same direction
		var current_acc = de_acc
		if (_dir.dot(hv) > 0):
			current_acc = acc
		
		hv = hv.linear_interpolate(_dir * speed, current_acc * delta)
		
		_velocity.x = hv.x
		_velocity.y -= delta * _gravity
		_velocity.z = hv.z
		
		# Moving and rotating towards target
		_velocity = move_and_slide(_velocity, Vector3(0,1,0), true)
		
		if _anim_tree.get("parameters/AttackShot/active"):
			return
		
		var delta_x = target.get_global_transform().origin.x - get_global_transform().origin.x
		var delta_z = target.get_global_transform().origin.z - get_global_transform().origin.z
		var angle = atan2(delta_x, delta_z) - global_transform.basis.get_euler().y
		global_rotate(Vector3(0,1,0), angle/10)
		
		var speed_blend = hv.length() * 2 / speed
		_anim_tree.set("parameters/Idle_Walk/blend_amount", speed_blend)
	elif not _anim_tree.get("parameters/AttackShot/active"):
		# Go back to spawn point
		var _dir = _spawn_point.origin - get_global_transform().origin

		if _spawn_point.origin.distance_to(get_global_transform().origin) <= spawn_tolerance_distance:
			_dir = Vector3()
			var angle = _spawn_point.basis.get_euler().y - global_transform.basis.get_euler().y
			global_rotate(Vector3(0,1,0), angle/10)

		_dir.y = 0
		_dir = _dir.normalized()
		
		var hv = _velocity
		hv.y = 0
		
		# If vectors are facing the same direction
		var current_acc = de_acc
		if (_dir.dot(hv) > 0):
			current_acc = acc
		
		hv = hv.linear_interpolate(_dir * speed, current_acc * delta)
		
		_velocity.x = hv.x
		_velocity.y -= delta * _gravity
		_velocity.z = hv.z
		
		# Moving and rotating towards target
		_velocity = move_and_slide(_velocity, Vector3(0,1,0), true)
		if _spawn_point.origin.distance_to(get_global_transform().origin) > spawn_tolerance_distance:
			var delta_x = _spawn_point.origin.x - get_global_transform().origin.x
			var delta_z = _spawn_point.origin.z - get_global_transform().origin.z
			var angle = atan2(delta_x, delta_z) - global_transform.basis.get_euler().y
			global_rotate(Vector3(0,1,0), angle/10)
		
		var speed_blend = hv.length() * 2 / speed
		_anim_tree.set("parameters/Idle_Walk/blend_amount", speed_blend)

func _on_player_in_area(body):
	chasing = true
	target = body

func _on_player_out_area(body):
	chasing = false
	target = null

func _on_Club_Hit(body):
	if body.is_in_group("player") and \
	   _anim_tree.get("parameters/AttackShot/active") and \
	   not _attack_shot:
			_attack_shot = true
			emit_signal("player_hitten", damage)
			
func _on_hit(damage):
	var _current_health = int($HUD/Control/Current.text)
	_current_health -= int(damage)
	
	if _current_health > 0:
		$HUD/Control/Current.text = str(_current_health)
		$HUD/Bar.value = _current_health
	else:
		queue_free()