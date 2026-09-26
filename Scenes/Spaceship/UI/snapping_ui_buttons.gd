extends HBoxContainer

@onready var button_l: Button = $ButtonL
@onready var button_r: Button = $ButtonR

var int_manager: InteractionManager

func _ready() -> void:
	button_l.pressed.connect(_on_l_pressed)
	button_r.pressed.connect(_on_r_pressed)

	button_l.focus_mode = Control.FOCUS_NONE
	button_r.focus_mode = Control.FOCUS_NONE

	int_manager = get_tree().get_first_node_in_group("Interaction_Manager")


func _on_l_pressed():
	SpaceshipEventBus.snap_ui_left.emit()


func _on_r_pressed():
	SpaceshipEventBus.snap_ui_right.emit()


func _process(_delta: float) -> void:
	if not int_manager:
		return

	visible = int_manager.current_inter.current_state == int_manager.current_inter.States.WAITING
