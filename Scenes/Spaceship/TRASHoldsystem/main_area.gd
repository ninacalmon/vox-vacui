class_name MainArea
extends Area2D

@export var zoom_in_amount: float = 3

@export var zoom_offset: Vector2 = Vector2.ZERO

@export var zoom_speed: float = 1

@export var clickable_highlight: ClickableHighlight

var is_focused: bool

var can_exit: bool = true

func _ready() -> void:
	clickable_highlight.was_clicked.connect(_on_clicked)
	#clickable_highlight.clicked_outside.connect(_was_clicked_outside)
	SpaceshipEventBus.focus_changed.connect(_on_focus_changed)

func activate_sub_areas():
	pass

func _on_clicked():
	if not is_focused:
		is_focused = true
		#trocar sprite aqui
		SpaceshipEventBus.focus_on.emit(zoom_in_amount, zoom_offset, self, false)

func _on_focus_changed(focus: bool, subject: Node2D):
	## If there is a race condition with the activation of the clickable_highlight
	## here and the disabling of it on the ClickableHighlight module, we can work
	## around this problem having a state here that changes clickable_highlight.active
	## on process based off this state
	if focus == false:
		clickable_highlight.active = true
		is_focused = false

	elif  focus == true and subject == self:
		activate_sub_areas()
