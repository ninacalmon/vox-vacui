extends SubArea

var was_counted: bool = false

var has_showed_text: bool = false

@onready var counter_text: ResourceCounter = %CounterText

@onready var sprite_valve: Sprite2D = $SpriteValve

func _ready() -> void:
	clickable_highlight.was_clicked.connect(_on_clicked)
	SpaceshipEventBus.resource_count_finished.connect(_on_resource_count_finished)

func _process(_delta: float) -> void:
	if clickable_highlight.is_mouse_over_area:
		if not has_showed_text and not was_counted:
			has_showed_text = true
			PopUpSystem.show_text("Clique para inserir fragmentos.", 3)
	else:
		has_showed_text = false

func _on_clicked():
	if was_counted:
		return
	was_counted = true
	can_exit_sub_area = false
	HandsEventBus.machine_interaction.emit()
	await get_tree().create_timer(0.5).timeout
	sprite_valve.frame = 0
	counter_text.initialize()

func _on_resource_count_finished():
	can_exit_sub_area = true
	SpaceshipEventBus.focus_off.emit(true)
	StatsManager.current_resources -= StatsManager.resources_needed
	SpaceshipEventBus.resources_spent.emit()
	Globals.has_energy_in_spaceship = true
