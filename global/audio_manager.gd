extends Node2D

signal talk_finished

@onready var food_sfx: AudioStreamPlayer2D = $FoodSFX
@onready var pumpkin_sfx: AudioStreamPlayer2D = $PumpkinSFX
@onready var game_sfx: AudioStreamPlayer2D = $GameSFX

func _ready() -> void:
	randomize()

func play_food_sound(food):
	var audio_path = "res://assets/food/" + food.to_lower() + "_audio.mp3"
	var audio_stream = ResourceLoader.load(audio_path)
	
	if audio_stream:
		play(food_sfx, audio_stream)
	else:
		print("Audio file not found: ", audio_path)

func play_pumpkin_sound(sound):
	var audio_path = "res://assets/pumpkin/audio/pumpkin_" + sound.to_lower() + "_audio.mp3"
	var audio_stream = ResourceLoader.load(audio_path)
	
	if audio_stream:
		play(pumpkin_sfx, audio_stream)
	else:
		print("Audio file not found: ", audio_path)

func play_giveme_sound(food):
	var random_int = randi_range(1, 3)
	var audio_path = "res://assets/pumpkin/audio/pumpkin_giveme" + str(random_int) + "_audio.mp3"
	var audio_stream = ResourceLoader.load(audio_path)
	
	if audio_stream:
		play(pumpkin_sfx, audio_stream)
	else:
		print("Audio file not found: ", audio_path)
		
	await pumpkin_sfx.finished
	
	audio_path = "res://assets/pumpkin/food_audio/pumpkin_" + food.to_lower() + "_audio.mp3"
	audio_stream = ResourceLoader.load(audio_path)
	
	if audio_stream:
		play(pumpkin_sfx, audio_stream)
	else:
		print("Audio file not found: ", audio_path)

func pumpkin_sfx_finished():
	pass

func play_game_sound(sound):
	var audio_path = "res://assets/audio/" + sound.to_lower() + "_audio.mp3"
	var audio_stream = ResourceLoader.load(audio_path)
	
	if audio_stream:
		play(game_sfx, audio_stream)
	else:
		print("Audio file not found: ", audio_path)

func play(type, audio_stream):
	if type != null:
		type.stream = audio_stream
		type.play()
	else:
		print("Audio type not found: " + type)

func _on_pumpkin_sfx_finished():
	if Global.game_state == "end":
		talk_finished.emit()
