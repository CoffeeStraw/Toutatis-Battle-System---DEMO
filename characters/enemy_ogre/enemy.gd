extends KinematicBody

var chasing = false
var target

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if chasing:
		pass


func _on_player_in_area(body):
	print("I CAN SEE YOU")
	chasing = true
	target = body

func _on_player_out_area(body):
	print("I MISS YOU!")
	chasing = false
	target = null
