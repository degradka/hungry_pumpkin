extends Node2D

@onready var sprite = $Sprite2D
@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer

func _ready():
	randomize()
	timer.wait_time = randi_range(5, 20)

func start_timer():
	timer.start()

func _on_timer_timeout():
	animation_player.play("ride")
