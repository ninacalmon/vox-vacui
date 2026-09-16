class_name Monitor
extends MainArea

@export var sub_area_screen: Screen

var has_energy: bool = false

var lights_on: bool = false

@onready var sprite_background: Sprite2D = $SpriteBackground

@onready var sprite_face: AnimatedSprite2D = $SpriteBackground/SpriteFace

func _ready() -> void:
	#has_energy = true
	_connect_signals()

func _process(_delta: float) -> void:
	if is_focused:
		can_exit = sub_area_screen.can_exit

func activate_sub_areas():
	sub_area_screen.activate()

func turn_lights_on():
	await get_tree().create_timer(1.5).timeout
	var tween = create_tween()
	tween.tween_property(sprite_background, "self_modulate", Color(8, 8, 8), 0.02)
	tween.tween_property(sprite_background, "self_modulate", Color(0.016, 0.016, 0.016, 1.0), 0.08)

func visual_state(state: bool):
	if not is_focused:
		return
	HandsEventBus.monitor.emit(false)
	var new_alpha: float
	if state:
		new_alpha = 0.07
	else:  new_alpha = 0

	var tween = create_tween()
	tween.tween_property(sprite_face, "modulate:a", new_alpha, 0.7)

func _connect_signals():
	clickable_highlight.was_clicked.connect(_on_clicked)
	SpaceshipEventBus.focus_changed.connect(_on_focus_changed)
	SpaceshipEventBus.resource_count_finished.connect(_on_resource_count_finished)

func _on_resource_count_finished():
	has_energy = true
	turn_lights_on()

func _on_clicked():
	if not has_energy or StatsManager.day == 3:
		HandsEventBus.not_yet.emit()
		if StatsManager.day != 3:
			PopUpSystem.show_text("Sem energia.")
		return

	if not is_focused and clickable_highlight.is_mouse_over_area:
		SpaceshipEventBus.focus_on.emit(zoom_in_amount, zoom_offset, self, false)

func _on_focus_changed(focus: bool, subject: Node2D):
	## If there is a race condition with the activation of the clickable_highlight
	## here and the disabling of it on the ClickableHighlight module, we can work
	## around this problem having a state here that changes clickable_highlight.active
	## on process based off this state
	if focus == false:
		visual_state(false)
		clickable_highlight.is_mouse_over_area = false
		clickable_highlight.active = true
		is_focused = false

	elif  focus == true and subject == self:
		is_focused = true
		HandsEventBus.monitor.emit(true)
		activate_sub_areas()
		visual_state(true)
