extends Camera

func _ready():
	# This detaches the camera transform from the parent spatial node
	set_as_toplevel(true)