extends Node

var enemies_on_screen: int

var is_showing_combat_guide: bool

var is_showing_confirm_guide: bool

var have_teleport: bool

func _ready() -> void:

	EventBus.enemy_on_screen.connect(_on_enemy_entered_screen)
	EventBus.enemy_off_screen.connect(_on_enemy_exited_screen)

	EventBus.mothership_entrance_entered.connect(_on_mothership_entrance_entered)
	EventBus.mothership_entrance_exited.connect(_on_mothership_entrance_exited)

	EventBus.boss_in_capture_area.connect(_on_boss_in_capture_area)

	have_teleport = Globals.can_teleport

	InputGuide.clear_guides()
	show_movement_guides()

func _input(event):
	if event is InputEventKey or event is InputEventMouse:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func show_movement_guides():
	InputGuide.show_guide(InputGuide.ActionType.MOVEMENT)
	InputGuide.show_guide(InputGuide.ActionType.IMPULSE)
	InputGuide.show_guide(InputGuide.ActionType.BREAK)
	InputGuide.show_guide(InputGuide.ActionType.FOCUS_OUT)
	if have_teleport:
		InputGuide.show_guide(InputGuide.ActionType.TELEPORT)

func show_combat_guides():
	InputGuide.show_guide(InputGuide.ActionType.AIM)
	InputGuide.show_guide(InputGuide.ActionType.SHOOT)

func _on_enemy_entered_screen():
	enemies_on_screen += 1
	if not is_showing_combat_guide:
		is_showing_combat_guide = true
		InputGuide.clear_guides()
		show_combat_guides()

func _on_enemy_exited_screen():
	enemies_on_screen -= 1
	if enemies_on_screen < 0:
		enemies_on_screen = 0
	if enemies_on_screen <= 0 and is_showing_combat_guide:
		is_showing_combat_guide = false
		InputGuide.clear_guides()
		show_movement_guides()

func _on_mothership_entrance_entered():
	if not is_showing_confirm_guide:
		is_showing_confirm_guide = true
		InputGuide.clear_guides()
		InputGuide.show_guide(InputGuide.ActionType.CONFIRM)

func _on_mothership_entrance_exited():
	if is_showing_confirm_guide:
		InputGuide.clear_guides()
		show_movement_guides()
		is_showing_confirm_guide = false

func _on_boss_in_capture_area(_bool: bool):
	if _bool:
		InputGuide.clear_guides()
		InputGuide.show_guide(InputGuide.ActionType.CONFIRM)
	else:
		InputGuide.clear_guides()
		show_movement_guides()
