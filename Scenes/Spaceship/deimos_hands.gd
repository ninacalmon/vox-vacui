extends Node2D

enum HandState {
	IDLE,
	NEGATIVE,
	MACHINE,
	BOOK_NEXT,
	BOOK_PREV,
	SNOT,
}

@export var camera: Camera2D

@onready var hands_animation: AnimatedSprite2D = $HandsAnimation

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var snot_timer: Timer = $SnotTimer

func _ready() -> void:
	#SpaceshipEventBus.focus_off.connect(_on_focus_off)
	snot_timer.timeout.connect(_on_snot_timer_timout)

	HandsEventBus.machine_interaction.connect(_on_machine_interaction)
	HandsEventBus.monitor.connect(_on_monitor)
	HandsEventBus.not_yet.connect(_on_door_interacted)
	HandsEventBus.book.connect(_on_book)
	hands_animation.play("Idle")


func _process(_delta: float) -> void:
	global_position = camera.global_position + camera.offset + Vector2(0, 120)


func _input(event: InputEvent) -> void:
	if event:
		snot_timer.start()

func _on_machine_interaction():
	animation_player.play("machine_interact")
	hands_animation.play("MachineInteract")
	await hands_animation.animation_finished
	animation_player.play("RESET")
	hands_animation.play("Idle")

func _on_monitor(state: bool):
	if state:
		animation_player.play("monitor")
	elif not state:
		animation_player.play_backwards("monitor")

func _on_door_interacted():
	hands_animation.play("Nananinanao")
	await hands_animation.animation_finished
	hands_animation.play("Idle")

func _on_book(state: bool):
	if state:
		hands_animation.play("HoldingBook")
	else:
		hands_animation.play("LettingGoOfBook")
		await hands_animation.animation_finished
		hands_animation.play("Idle")

func _on_snot_timer_timout():
	if not (hands_animation.animation == "Idle"):
		return
	hands_animation.play("Meleca")
	await hands_animation.animation_finished
	hands_animation.play("Idle")
	snot_timer.start()
