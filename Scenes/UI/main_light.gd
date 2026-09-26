class_name FlickeringLight
extends PointLight2D

@export var first_flicker_interval_min: int = 2

@export var first_flicker_interval_max: int = 4

@export var flicker_interval_min: int = 10

@export var flicker_interval_max: int = 40

var original_energy: float

var timer: Timer

var audio_stream_player: AudioStreamPlayer

var electric_sound: AudioStream  = preload("res://sound_effects/spaceship/buzz.ogg")

func initialize() -> void:
	if timer:
		return

	timer = Timer.new()
	timer.wait_time = randi_range(first_flicker_interval_min, first_flicker_interval_max)
	audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.bus = "Sound Effects"
	audio_stream_player.stream = electric_sound
	self.add_child(timer)
	self.add_child(audio_stream_player)
	timer.timeout.connect(flicker)
	timer.start()

func flicker():
	timer.stop()
	audio_stream_player.volume_db = randf_range(-26, -22)
	audio_stream_player.pitch_scale = randf_range(1.8, 2.4)
	audio_stream_player.play()
	self.energy = 0
	var flicker_tween = get_tree().create_tween()
	flicker_tween.tween_property(self, "energy", original_energy, 0.2)
	await flicker_tween.finished
	self.energy = 0

	await get_tree().create_timer(0.1).timeout
	self.energy = original_energy
	timer.start(randi_range(flicker_interval_min, flicker_interval_max))
