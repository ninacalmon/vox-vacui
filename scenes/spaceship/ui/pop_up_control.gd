extends CanvasLayer

signal text_vanished

@export var original_bottom_text: RichTextLabel

@export var v_box_bottom: VBoxContainer

@export var flash_color: Color

@export var texts_limit: int = 1

var texts_count: int = 0

func _ready() -> void:
	original_bottom_text.hide()

func show_text(new_text: String, duration: float = 3.0):
	if texts_count >= texts_limit:
		return
	texts_count += 1
	var bottom_text: RichTextLabel = original_bottom_text.duplicate()
	v_box_bottom.add_child(bottom_text)
	bottom_text.text = new_text
	bottom_text.show()
	await flash(bottom_text, false)
	await get_tree().create_timer(duration).timeout
	await flash(bottom_text, true)
	bottom_text.hide()
	bottom_text.call_deferred("queue_free")
	texts_count -= 1
	text_vanished.emit()

func flash(subject: CanvasItem, invisible: bool):
	var original_modulate: Color = subject.modulate
	subject.modulate = flash_color
	await get_tree().create_timer(0.1).timeout
	var tween = create_tween()
	var final_color: Color
	if invisible:
		final_color = Color(0, 0, 0, 0)
	else:
		final_color = original_modulate
	tween.tween_property(subject, "modulate", final_color, 0.2)
	await tween.finished

func clear():
	for p in v_box_bottom.get_children():
		p.hide()
