class_name SpaceshipCam
extends Camera2D

@export var min_offset: int = -200

@export var max_offset: int = 200

@export var offset_strength_x: float = 0.1

@export var offset_strength_y: float = 0.2

@export var pixel_rect: ColorRect

var is_busy: bool

var is_focused: bool

@onready var pan_view_module: PanViewModule = $PanViewModule

@onready var focus_module: FocusModule = $FocusModule

func _ready() -> void:
	pan_view_module.initialize()
	focus_module.initialize()

func _process(_delta):
	if is_focused and not (focus_module.subject is Papers):
		return

	var screen_center = get_screen_center_position()
	var mouse_offset = get_global_mouse_position() - screen_center

	var new_offset = Vector2(
	mouse_offset.x * offset_strength_x,
	mouse_offset.y * offset_strength_y
	)

	new_offset.x = clamp(new_offset.x, min_offset, max_offset)
	new_offset.y = clamp(new_offset.y, min_offset, max_offset)

	offset = offset.lerp(new_offset, 0.1)

	var mat: ShaderMaterial = pixel_rect.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("camera_pos", global_position + offset)

func update_current_room():
	pan_view_module.update_current_room()
