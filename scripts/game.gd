extends Node2D

@onready var foreground = $Level/Foreground

@onready var camera = $Camera
@onready var play_button = $UI/Control/PlayButton
@onready var walker = $Level/Street/Walker
@onready var walker_anim = $Level/Street/Walker/AnimationPlayer
@onready var pumpkin = $Level/Foreground/Pumpkin
@onready var pumpkin_head = $Level/Foreground/Pumpkin/Head
@onready var pumpkin_hand_left = $Level/Foreground/Pumpkin/HandLeft
@onready var score_animation = $UI/Control/ScorePanel/AnimationPlayer
@onready var score_label = $UI/Control/ScorePanel/Back/ScoreLabel
@onready var car = $Level/Street/Car

@onready var starting_point = $Level/Foreground/Top/FoodChoice/StartingPoint
@onready var slot_01 = $Level/Foreground/Top/FoodChoice/Slot01
@onready var slot_02 = $Level/Foreground/Top/FoodChoice/Slot02
@onready var slot_03 = $Level/Foreground/Top/FoodChoice/Slot03
@onready var slot_04 = $Level/Foreground/Top/FoodChoice/Slot04
@onready var plate = $Level/Foreground/Top/FoodChoice/Plate
@onready var mouth = $Level/Foreground/Top/FoodChoice/Mouth

const BAR_POS: Vector2 = Vector2(350.0, 285.0) # min 280, intially 250 (but bar top is visible which is meh)
const RESTAURANT_POS: Vector2 = Vector2(350.0, -160.0)

var game_started = false
var food_names = ["hamburger", "pizza", "sandwich", "hotdog", "fries", "eggs", "chicken", "butter", "cheese", "bread", "rice", "noodles", "salt", "pepper", "fish", "jam", "icewater", "orangejuice", "soda", "coffee"]
var served = []
var head_anim = ""
var game_count = 0
var is_fullscreen: bool = false

func set_globals_to_default():
	Global.is_hovering = false
	Global.score = 0
	Global.is_bar = true
	Global.game_state = "bar"
	Global.ordered = ""
	Global.user_pick = ""
	Global.can_pick = false
	Global.is_no = false

	Global.random_food_list = []

func _ready():
	set_globals_to_default()
	AudioManager.connect("talk_finished", outro)
	walker.hide()
	score_label.text = str(Global.score)
	Global.random_food_list = make_random_list()

func make_random_list() -> Array:
	var shuffled_list = food_names
	shuffled_list.shuffle()
	
	return shuffled_list

func update_cursor():
	if !Global.is_hovering:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func change_view():
	if Global.is_bar:
		Global.is_bar = false
		camera.position = RESTAURANT_POS

func fullscreen_toggle():
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		is_fullscreen = false
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		is_fullscreen = true

func _on_play_button_pressed():
	change_view()
	play_button.queue_free()
	walker.get_node("AnimationPlayer").play("intro")
	Global.game_state = "intro"
	game_started = true

func _process(_delta):
	update_cursor()
	
	if Input.is_action_just_pressed("fullscreen_toggle"):
		fullscreen_toggle()
	
	if Global.game_state == "choice":
		if Global.user_pick != "" and Global.ordered != "":
			var user_pick = Global.user_pick
			Global.user_pick = ""
			if user_pick == Global.ordered:
				handle_correct_food(user_pick)
			elif user_pick != Global.ordered:
				handle_incorrect_food(user_pick)

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"intro":
			walker.hide()
			game_start()
		"end":
			await get_tree().create_timer(3).timeout
			get_tree().reload_current_scene()

func walker_play_sound():
	AudioManager.play_pumpkin_sound("imveryhungry")

func game_start():
	car.start_animation_timer()
	pumpkin_head.scale = Vector2(0.85, 0.85)
	pumpkin.show()
	score_animation.play("show")
	Global.can_pick = false
	serve()

func add_score() -> void:
	Global.score += 1
	AudioManager.play_game_sound("score")
	score_animation.play("score")
	score_label.text = str(Global.score)
	pumpkin_head.scale += Vector2(0.0075, 0.0075)

func serve_one(food, slot) -> void:	
	var food_scene = ResourceLoader.load("res://scenes/food/" + food + ".tscn")
	var food_instance = food_scene.instantiate()
	
	var slot_variable = "slot_0" + str(slot)
	
	foreground.add_child(food_instance)
	food_instance.position = starting_point.global_position
	food_instance.z_index += 1
	
	var tween = create_tween()
	
	tween.tween_property(food_instance, "position", get(slot_variable).global_position, 1.0)
	
	served.append(food)

func serve() -> void:
	var i = 1
	while i <= 4:
		serve_one(Global.random_food_list[(i + game_count) - 1], i)
		i += 1
	game_count += 4
	Global.can_pick = false
	after_serve()

func after_serve() -> void:
	Global.ordered = served.pick_random()
	AudioManager.play_giveme_sound(Global.ordered)
	pumpkin_head.play("order")
	head_anim = "order"
	Global.game_state = "choice"

func try_again() -> void:
	AudioManager.play_giveme_sound(Global.ordered)
	pumpkin_head.play("order")
	head_anim = "order"
	Global.game_state = "choice"

func handle_correct_food(user_pick):
	Global.can_pick = false
	Global.ordered = ""
	var food = user_pick.capitalize()

	if user_pick == "orange_juice" or user_pick == "orangejuice":
		food = "OrangeJuice"
	elif user_pick == "ice_water" or user_pick == "icewater":
		food = "IceWater"
	
	food = foreground.get_node_or_null(food)
	if food == null:
		return
	
	await get_tree().create_timer(0.4).timeout
	pumpkin_hand_left.play("eat")
	pumpkin_head.play("eat")
	head_anim = "eat"
	AudioManager.play_pumpkin_sound("eat")
	
	if food != null:
		food.move_to_mouth()
		served.erase(user_pick)

func handle_incorrect_food(user_pick):
	Global.can_pick = false
	var food = user_pick.capitalize()

	if user_pick == "orangejuice":
		food = "OrangeJuice"
	elif user_pick == "icewater":
		food = "IceWater"
	
	food = foreground.get_node_or_null(food)
	if food == null:
		return
	
	await get_tree().create_timer(0.4).timeout
	pumpkin_hand_left.play("no")
	pumpkin_head.play("no")
	head_anim = "no"
	Global.is_no = true
	AudioManager.play_pumpkin_sound("noidontwantthat")
	
	if food != null:
		food.move_to_trash()
		served.erase(user_pick)

func ending():
	Global.game_state = "end"
	Global.is_no = true
	pumpkin_head.play("talk")
	if Global.score < 7:
		AudioManager.play_pumpkin_sound("terrible")
	elif Global.score < 16:
		AudioManager.play_pumpkin_sound("notbad")
	elif Global.score < 19:
		AudioManager.play_pumpkin_sound("delicious")
	else:
		AudioManager.play_pumpkin_sound("fantastic")

func outro():
	pumpkin.hide()
	walker_anim.play("end")
	Global.can_pick = false

func _on_head_animation_finished():
	if head_anim == "eat":
		head_anim = ""
		add_score()
		Global.can_pick = true
		pumpkin_hand_left.play("idle")
		pumpkin_head.play("idle")
		head_anim = "idle"
		if !served.is_empty():
			after_serve()
		else:
			if game_count < 20:
				serve()
			else:
				ending()
	elif head_anim == "no":
		head_anim = ""
		Global.can_pick = true
		Global.is_no = false
		pumpkin_hand_left.play("idle")
		pumpkin_head.play("idle")
		head_anim = "idle"
		if !served.is_empty():
			try_again()
		else:
			if game_count < 20:
				serve()
			else:
				ending()
	elif head_anim == "order":
		head_anim = ""
		Global.can_pick = true
		pumpkin_hand_left.play("idle")
		pumpkin_head.play("idle")
		head_anim = "idle"
