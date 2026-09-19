extends Control

@onready var hands_animation_prev: AnimatedSprite2D = $HandsAnimationPREV

@onready var hands_animation_next: AnimatedSprite2D = $HandsAnimationNEXT

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	hands_animation_next.hide()
	hands_animation_prev.hide()
	HandsEventBus.page_next.connect(_on_page_next)
	HandsEventBus.page_prev.connect(_on_page_prev)

func _on_page_next():
	HandsEventBus.hand_is_busy = true
	hands_animation_next.show()
	animation_player.play("next_hand_show")
	hands_animation_next.play("FlippingPagesBookNEXT")
	await hands_animation_next.animation_finished
	animation_player.play_backwards("prev_hand_show")
	await animation_player.animation_finished
	hands_animation_next.hide()
	HandsEventBus.hand_is_busy = false

func _on_page_prev():
	HandsEventBus.hand_is_busy = true
	hands_animation_prev.show()
	animation_player.play("prev_hand_show")
	hands_animation_prev.play("FlippingPagesBookBACK")
	await hands_animation_prev.animation_finished
	animation_player.play_backwards("prev_hand_show")
	await animation_player.animation_finished
	hands_animation_prev.hide()
	HandsEventBus.hand_is_busy = false
