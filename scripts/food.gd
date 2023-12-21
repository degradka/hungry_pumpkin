extends Node2D

@onready var arrow: AnimatedSprite2D = $Arrow
@onready var area: Area2D = $Area

@onready var plate = get_node("/root/Game/Level/Foreground/Top/FoodChoice/Plate")
@onready var mouth = get_node("/root/Game/Level/Foreground/Top/FoodChoice/Mouth")
@onready var trash = get_node("/root/Game/Level/Foreground/Top/FoodChoice/Trash")

func _ready():
	area.connect("mouse_entered", mouse_entered)
	area.connect("mouse_exited", mouse_exited)
	area.connect("input_event", input_event)

func mouse_entered() -> void:
	if Global.game_state == "choice":
		if Global.can_pick:
			arrow.show()
	else:
		arrow.show()

func mouse_exited() -> void:
	arrow.hide()
	Global.is_hovering = false

func input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		if Global.is_bar:
			AudioManager.play_food_sound(name)
		elif Global.game_state == "choice" and Global.can_pick:
			Global.user_pick = name.to_lower()
			move_to_plate()

func move_to_plate():
	var tween = create_tween()
	tween.tween_property(self, "position", plate.global_position, 0.2)

func move_to_mouth():
	var tween = create_tween()
	tween.tween_property(self, "position", mouth.global_position, 0.2)
	await tween.finished
	queue_free()

func move_to_trash():
	var tween = create_tween()
	tween.tween_property(self, "position", trash.global_position, 0.2)
	await tween.finished
	queue_free()
