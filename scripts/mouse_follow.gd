extends Marker2D

@onready var child = get_children()[0]

var max_dist: int = 10

func _process(_delta):
	var mouse_pos = get_local_mouse_position()
	var dir = Vector2.ZERO.direction_to(mouse_pos)
	var dist = mouse_pos.length()
	child.position = dir * min(dist, max_dist)
