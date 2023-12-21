extends AnimatedSprite2D

func _process(_delta):
	if visible:
		Global.is_hovering = true
