class_name PowerUpUI
extends Control

@export var power_up_options_array: Array[PowerUpSetup]

@onready var power_up_pop_up_sfx: AudioStreamPlayer = $PowerUpPopUpSFX

var _cancel_show: bool = false
var _current_tween: Tween


func _ready() -> void:
	hide()


func show_power_ups() -> void:
	_cancel_show = false

	if _current_tween:
		_current_tween.kill()

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	show()

	for p in power_up_options_array:
		p.hide()

	for p in power_up_options_array:
		if _cancel_show:
			return

		p.show()

		SFXManager.play_sound(power_up_pop_up_sfx)

		_current_tween = flash(p)

		# Wait for this PU's flash before revealing the next one.
		await get_tree().create_timer(0.24).timeout

		if _cancel_show:
			return

	if not _cancel_show and not power_up_options_array.is_empty():
		power_up_options_array[0]._grab_focus()


func hide_power_ups() -> void:
	_cancel_show = true

	if _current_tween:
		_current_tween.kill()
		_current_tween = null

	var tweens: Array[Tween] = []

	for p in power_up_options_array:
		if not p.visible:
			continue

		tweens.append(flash(p))

	# All flashes have already started, so they happen simultaneously.
	await get_tree().create_timer(0.24).timeout

	for p in power_up_options_array:
		p.hide()

	hide()

	CustomTooltip.hide_tooltip()

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func flash(what: Control) -> Tween:
	var original_color := what.modulate

	var tween := get_tree().create_tween()

	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		what,
		"modulate",
		Color(0, 0, 0, 1),
		0.02
	)
	tween.tween_property(
		what,
		"modulate",
		Color(10, 10, 10, 10),
		0.07
	)
	tween.tween_property(
		what,
		"modulate",
		original_color,
		0.15
	)

	return tween


#class_name PowerUpUI
#extends Control
#
#@export var power_up_options_array: Array[PowerUpSetup]
#
#@onready var power_up_pop_up_sfx: AudioStreamPlayer = $PowerUpPopUpSFX
#
#var _break: bool = false
#
#
#func _ready() -> void:
	#hide()
#
#
#func show_power_ups():
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
#
	#if _break:
		#return
	#
	#show()
#
	#for p in power_up_options_array:
#
		#if _break:
			#return
#
		#p.show()
#
		#SFXManager.play_sound(power_up_pop_up_sfx)
#
		#if _break:
			#return
	#
		#await flash(p, p.modulate)
#
		#if _break:
			#return
#
	#var first_pu: PowerUpSetup = power_up_options_array.get(0)
	#first_pu._grab_focus()
#
#
#func hide_power_ups():
	#_break = true
	#for p in power_up_options_array:
		#flash(p, p.modulate)
		#p.hide()
	#_break = false
	#hide()
#
	#CustomTooltip.hide_tooltip()
#
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
#
#
#func flash(what: Control, original_color):
	#var tween = get_tree().create_tween()
	#tween.set_ease(Tween.EASE_IN_OUT)
	#tween.tween_property(what, "modulate", Color(0, 0, 0, 1), 0.02)
	#tween.tween_property(what, "modulate", Color(10, 10, 10, 10), 0.07)
	#tween.tween_property(what, "modulate", original_color, 0.3)
	#await tween.finished
