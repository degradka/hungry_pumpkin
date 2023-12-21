extends Node2D

signal talk_finished

@onready var food_sfx: AudioStreamPlayer2D = $FoodSFX
@onready var pumpkin_sfx: AudioStreamPlayer2D = $PumpkinSFX
@onready var game_sfx: AudioStreamPlayer2D = $GameSFX

func _ready() -> void:
	randomize()

func play_sound(player, path, sound):
	var audio_path = "res://assets/" + path + "/" + sound.to_lower() + "_audio.mp3"
	var audio_stream = ResourceLoader.load(audio_path)
	
	if audio_stream:
		play(player, audio_stream)
	else:
		print("Audio file not found: ", audio_path)

func play(player, audio_stream):
	if player != null:
		player.stream = audio_stream
		player.play()
	else:
		print("Audio player not found: " + player)

func play_food_sound(food):
	play_sound(food_sfx, "food", food)

func play_game_sound(sound):
	play_sound(game_sfx, "audio", sound)

func play_pumpkin_sound(sound):
	play_sound(pumpkin_sfx, "pumpkin/audio", "pumpkin_" + sound.to_lower())

func play_giveme_sound(food):
	var random_int = randi_range(1, 3)
	var audio_path = "res://assets/pumpkin/audio/pumpkin_giveme" + str(random_int) + "_audio.mp3"
	var audio_stream = ResourceLoader.load(audio_path)
	
	if audio_stream:
		play(pumpkin_sfx, audio_stream)
	else:
		print("Audio file not found: ", audio_path)
		
	await pumpkin_sfx.finished
	
	if Global.is_no:
		return
	
	audio_path = "res://assets/pumpkin/food_audio/pumpkin_" + food.to_lower() + "_audio.mp3"
	audio_stream = ResourceLoader.load(audio_path)
	
	if audio_stream:
		play(pumpkin_sfx, audio_stream)
	else:
		print("Audio file not found: ", audio_path)

func _on_pumpkin_sfx_finished():
	if Global.game_state == "end":
		talk_finished.emit()
