extends Line2D

# Settings
export(float) var trail_length = 10

# Internal variables
var _offset = {'x': 20, 'y': 20}
var _point

func _process(delta):
	_point = get_global_mouse_position()
	_point.x += _offset.x
	_point.y += _offset.y
	add_point( _point )
	
	while(get_point_count() > trail_length):
		remove_point(0)