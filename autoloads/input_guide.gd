extends CanvasLayer

# ENUMS
enum InputDevice {
	KEYBOARD,
	CONTROLLER,
}

enum ActionType {
CONFIRM, RETURN, TELEPORT,
MOVEMENT, IMPULSE, BREAK,
AIM, SHOOT,
POINT, CLICK, UI_MOVEMENT, 
SKIP, NEXT,
CHANGE_ITEM, INTERACT, CHANGE_PAGE
}

# ICONS CONTROLER
const A_BUTTON: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0004.png")

const B_BUTTON: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0005.png")

const Y_BUTTON: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0007.png")

const X_BUTTON: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0006.png")

const L_TRIGGER: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0621.png")

const R_TRIGGER: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0622.png")

const L_SHOULDER: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0623.png")

const R_SHOULDER: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0624.png")

const L_ANALOG: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0423.png")

const R_ANALOG: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0491.png")

const L_ANALOG_HORIZONTAL: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0825.png")

const D_PAD: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0034.png")

# ICONS KEYBOARD
const SPACE_KEY: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0801.png")

const X_KEY: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0156.png")

const T_KEY: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0089.png")

const WASD_KEY: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0816.png")

const AD_KEY: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0824.png")

const SHIFT_KEY: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0819.png")

const CTRL_KEY: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0820.png")

const MOUSE: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0076.png")

const CURSOR: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0822.png")

const L_CLICK: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0077.png")

const R_CLICK: CompressedTexture2D = preload("res://sprites/ui/kenney_input/tile_0078.png")

const INPUT_ICONS: Dictionary = {
	ActionType.CONFIRM: {
		InputDevice.CONTROLLER: A_BUTTON,
		InputDevice.KEYBOARD: SPACE_KEY
	},
	ActionType.RETURN: {
		InputDevice.CONTROLLER: B_BUTTON,
		InputDevice.KEYBOARD: X_KEY
	},
	ActionType.TELEPORT: {
		InputDevice.CONTROLLER: Y_BUTTON,
		InputDevice.KEYBOARD: T_KEY
	},
	ActionType.MOVEMENT: {
		InputDevice.CONTROLLER: L_ANALOG,
		InputDevice.KEYBOARD: WASD_KEY
	},
	ActionType.IMPULSE: {
		InputDevice.CONTROLLER: R_TRIGGER,
		InputDevice.KEYBOARD: SHIFT_KEY
	},
	ActionType.BREAK: {
		InputDevice.CONTROLLER: L_TRIGGER,
		InputDevice.KEYBOARD: CTRL_KEY
	},
	ActionType.AIM: {
		InputDevice.CONTROLLER: R_ANALOG,
		InputDevice.KEYBOARD: CURSOR
	},
	ActionType.SHOOT: {
		InputDevice.CONTROLLER: R_SHOULDER,
		InputDevice.KEYBOARD: L_CLICK
	},
	ActionType.POINT: {
		InputDevice.CONTROLLER: L_ANALOG,
		InputDevice.KEYBOARD: CURSOR,
	},
	ActionType.CLICK : {
		InputDevice.CONTROLLER: A_BUTTON,
		InputDevice.KEYBOARD: L_CLICK,
	},
	ActionType.UI_MOVEMENT : {
		InputDevice.CONTROLLER: L_ANALOG,
		InputDevice.KEYBOARD: WASD_KEY,
	},
	ActionType.SKIP : {
		InputDevice.CONTROLLER: B_BUTTON,
		InputDevice.KEYBOARD: X_KEY,
	},
	ActionType.NEXT : {
		InputDevice.CONTROLLER: A_BUTTON,
		InputDevice.KEYBOARD: SPACE_KEY
	},
	ActionType.CHANGE_ITEM : {
		InputDevice.CONTROLLER: L_ANALOG_HORIZONTAL,
		InputDevice.KEYBOARD: AD_KEY,
	},
	ActionType.INTERACT : {
		InputDevice.CONTROLLER: A_BUTTON,
		InputDevice.KEYBOARD: SPACE_KEY
	},
	ActionType.CHANGE_PAGE : {
		InputDevice.CONTROLLER: L_ANALOG_HORIZONTAL,
		InputDevice.KEYBOARD: AD_KEY,
	},
}

# TEXT
const COMMON_ACTIONS: Dictionary = {
	ActionType.CONFIRM: "Confirmar",
	ActionType.RETURN: "Retornar",
	ActionType.TELEPORT: "Teleportar",
	ActionType.MOVEMENT: "Ativar propulsor",
	ActionType.IMPULSE: "Impulso",
	ActionType.BREAK: "Frear",
	ActionType.AIM: "Mirar",
	ActionType.SHOOT: "Disparar",
	ActionType.POINT: "Mirar",
	ActionType.CLICK: "Selecionar",
	ActionType.UI_MOVEMENT: "Navegar UI",
	ActionType.SKIP: "Ignorar",
	ActionType.NEXT: "Avançar",
	ActionType.CHANGE_ITEM: "Trocar item",
	ActionType.INTERACT: "Interagir",
	ActionType.CHANGE_PAGE: "Trocar página"
}

@export var hidden_guide_array: Array[InputGuideUnit]

var active_guide_array: Array[InputGuideUnit]

var current_input_device: InputDevice = InputDevice.KEYBOARD

var final_unit_alpha: float = 1

func _ready() -> void:
	for i in hidden_guide_array:
		i.hide()
		i.modulate.a = 0

func _input(event):
	if event is InputEventKey or event is InputEventMouse:
		if Globals.fake_mouse_input:
			return
		set_input_device(InputDevice.KEYBOARD)

	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		set_input_device(InputDevice.CONTROLLER)

func set_input_device(device: InputDevice):
	if current_input_device == device:
		return

	current_input_device = device

	for guide in active_guide_array:
		var action: ActionType = guide.action as ActionType
		var new_icon = INPUT_ICONS[action][current_input_device]
		guide.set_icon(new_icon)

func show_guide(action: ActionType, duration: float = 0) -> InputGuideUnit:
	if hidden_guide_array.is_empty():
		if active_guide_array.is_empty():
			return null
		hidden_guide_array.append(active_guide_array.pop_back())

	var guide_unit: InputGuideUnit = hidden_guide_array.pop_front()

	var icon = INPUT_ICONS[action][current_input_device]
	var text = COMMON_ACTIONS[action]

	guide_unit.setup(icon, text, action)

	guide_unit.show()
	flash(guide_unit)
	active_guide_array.append(guide_unit)
	guide_unit.get_parent().move_child(guide_unit, active_guide_array.size() - 1)

	if duration != 0:
		hide_guide(guide_unit, duration)

	return guide_unit

func hide_guide(guide_unit: InputGuideUnit, duration: float = 0):
	await get_tree().create_timer(duration).timeout

	if active_guide_array.is_empty():
		return

	if not active_guide_array.has(guide_unit):
		return

	active_guide_array.erase(guide_unit)
	hidden_guide_array.append(guide_unit)
	await vanish(guide_unit)
	guide_unit.hide()

func clear_guides():
	for guide in active_guide_array:
		guide.hide()
		guide.modulate.a = 0
		hidden_guide_array.append(guide)

	active_guide_array.clear()

# ANIMATIONS
func flash(subject: Control):
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(subject, "modulate:a", 1, 0.02)
	tween.tween_property(subject, "modulate:a", final_unit_alpha, 0.1)

func vanish(subject: Control):
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(subject, "modulate:a", 1, 0.02)
	tween.tween_property(subject, "modulate:a", 0, 0.1)
	await tween.finished
