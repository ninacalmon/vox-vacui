class_name ResourcesMachine
extends ActionExecutor

@onready var shake_module: ShakeModule = $ShakeModule
@onready var sprite_valve: Sprite2D = $SpriteValve
@onready var resource_counter: ResourceCounter = $ResourceCounter

var waiting_input: bool = false

var was_used: bool = false

var message: String = "Inserir fragmentos"


func start():
	current_state = States.BLOCKED

	pcam.set_priority(2000)

	waiting_input = true
	sprite_valve.set_instance_shader_parameter("enabled", true)
	PopUpSystem.show_text(message, 2)

	current_state = States.FREE


func finish():
	sprite_valve.set_instance_shader_parameter("enabled", false)

	waiting_input = false
	current_state = States.FREE
	pcam.set_priority(0)


func _input(event: InputEvent) -> void:
	if not waiting_input:
		return

	if event.is_action_pressed("confirm"):
		if was_used:
			HandsEventBus.not_yet.emit()
			current_state = States.FREE
			was_freed.emit()
			return

		was_used = true
		message = "Já foi usado hoje."
		current_state = States.BLOCKED
		SpaceshipEventBus.resource_count_started.emit(resource_counter.calculate_duration())

		await count_resources()

		SpaceshipEventBus.resource_count_finished.emit()
		Globals.spaceship_energy = true

		current_state = States.FREE
		was_freed.emit()


func count_resources():
		current_state = States.BLOCKED

		HandsEventBus.machine_interaction.emit()
		await get_tree().create_timer(0.5).timeout
		sprite_valve.frame = 0
		shake_module.shake(self, resource_counter.calculate_duration() * 1.5, 0.5)

		await resource_counter.execute()

		StatsManager.current_resources -= StatsManager.resources_needed
		SpaceshipEventBus.resources_spent.emit()
		Globals.has_energy_in_spaceship = true



#func _ready() -> void:
	#_connect_signals()

#func _process(_delta: float) -> void:
	#if is_focused:
		#can_exit = sub_area_resources_deposit.can_exit_sub_area

#func activate_sub_areas():
	#sub_area_resources_deposit.clickable_highlight.active = true

#func change_to_focused():
	#SpaceshipEventBus.focus_on.emit(zoom_in_amount, zoom_offset, self, false)
	##trocar sprite aqui

#func _connect_signals():
	#clickable_highlight.was_clicked.connect(_on_clicked)
	##clickable_highlight.clicked_outside.connect(_was_clicked_outside)
	#SpaceshipEventBus.focus_changed.connect(_on_focus_changed)
	#SpaceshipEventBus.resource_count_started.connect(_on_resource_count_started)

#func _on_clicked():
	#if StatsManager.day == 3:
		#HandsEventBus.not_yet.emit()
		##PopUpSystem.show_text("Não.")
		#return
	#if not is_focused and clickable_highlight.is_mouse_over_area:
		#change_to_focused()

#func _on_focus_changed(focus: bool, subject: Node2D):
	### If there is a race condition with the activation of the clickable_highlight
	### here and the disabling of it on the ClickableHighlight module, we can work
	### around this problem having a state here that changes clickable_highlight.active
	### on process based off this state
	#if focus == false:
		#clickable_highlight.active = true
		#clickable_highlight.is_mouse_over_area = false
		#is_focused = false
#
	#elif  focus == true and subject == self:
		#is_focused = true
		#activate_sub_areas()
