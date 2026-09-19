#class_name Screen
#extends SubArea
#
#@export var canvas_layer_monitor: CanvasLayer
#
#@export var power_ups_conteiner: PowerUpList
#
#var can_exit: bool
#
#@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
#
#func _ready() -> void:
	#SpaceshipEventBus.focus_changed.connect(_on_focus_changed)
	#canvas_layer_monitor.hide()
#
#func _process(_delta: float) -> void:
	#can_exit = power_ups_conteiner.is_on
#
#func activate():
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#canvas_layer_monitor.show()
	#power_ups_conteiner.initialize()
#
#func deactivate():
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#canvas_layer_monitor.hide()
	#CustomTooltip.hide_tooltip()
	#await power_ups_conteiner.hide_power_ups()
	#power_ups_conteiner.is_on = false
#
#func _on_focus_changed(focus: bool, _subject: Node2D):
	#if focus == false:
		#deactivate()
