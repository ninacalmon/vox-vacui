class_name Diary
extends ActionExecutor


@onready var sprite_mini_book: Sprite2D = $SpriteMiniBook

@onready var sprite_open: Sprite2D = $BookCanvasLayer/SpriteOpen

@onready var animation_take_book: AnimationPlayer = $SpriteMiniBook/AnimationTakeBook

@onready var animation_book_open: AnimationPlayer = $BookCanvasLayer/SpriteOpen/AnimationBookOpen

@onready var diary_control: DiaryPageController = $BookCanvasLayer/DiaryControl

@onready var blur_rect: ColorRect = $BookCanvasLayer/BlurRect


func start():
	current_state = States.BLOCKED

	await _take_book()
	diary_control.is_open = true

	current_state = States.FREE


func finish():
	current_state = States.FREE

	diary_control.is_open = false
	await _close_book()



func _ready() -> void:
	blur_rect.hide()
	diary_control.hide()
	sprite_open.hide()


func slow_color_change(
	subject: Node, duration: float = 0.5, final_modulate: Color = Color(1, 1, 1, 0)
):
	var tween = create_tween()
	tween.tween_property(subject, "modulate", final_modulate, duration)
	await tween.finished



# Animations vvvvvvvvvvvv
func _take_book():
	animation_take_book.play("take_book")
	await get_tree().create_timer(animation_take_book.current_animation_length * 0.9).timeout
	HandsEventBus.book.emit(true)
	await _open_book()


func _open_book():
	diary_control.open_diary()
	_show_blur()
	await _play_open_animation()
	_show_book_ui()



func _close_book():
	await _hide_book_ui()
	await _play_close_animation()
	HandsEventBus.book.emit(false)
	_hide_blur()

	_return_book()

func _return_book():
	animation_take_book.play_backwards("take_book")
	await animation_take_book.animation_finished

# Visual Steps vvvvvvvv
func _show_blur():
	blur_rect.modulate.a = 0
	blur_rect.show()
	slow_color_change(blur_rect, 0.5, Color(1, 1, 1, 1))

func _hide_blur():
	slow_color_change(blur_rect, 0.5)
	blur_rect.hide()

func _play_open_animation():
	sprite_open.show()
	animation_book_open.play("open_book")
	await get_tree().create_timer(animation_book_open.current_animation_length).timeout

func _play_close_animation():
	animation_book_open.play_backwards("open_book")
	await get_tree().create_timer(animation_book_open.current_animation_length).timeout
	sprite_open.hide()

func _show_book_ui():
	diary_control.modulate.a = 0
	diary_control.show()
	slow_color_change(diary_control, 0.2, Color(1, 1, 1, 1))

func _hide_book_ui():
	slow_color_change(diary_control, 0.2)
	await get_tree().create_timer(0.2).timeout
	diary_control.hide()
