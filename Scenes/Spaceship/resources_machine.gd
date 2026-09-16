class_name ResourcesMachine
extends MainArea

@export var sub_area_resources_deposit: SubArea

@onready var sprite_main: Sprite2D = $SpriteMain

@onready var shake_module: ShakeModule = $ShakeModule

func _ready() -> void:
	_connect_signals()

func _process(_delta: float) -> void:
	if is_focused:
		can_exit = sub_area_resources_deposit.can_exit_sub_area

func activate_sub_areas():
	sub_area_resources_deposit.clickable_highlight.active = true

func change_to_focused():
	SpaceshipEventBus.focus_on.emit(zoom_in_amount, zoom_offset, self, false)
	#trocar sprite aqui

func _connect_signals():
	clickable_highlight.was_clicked.connect(_on_clicked)
	#clickable_highlight.clicked_outside.connect(_was_clicked_outside)
	SpaceshipEventBus.focus_changed.connect(_on_focus_changed)
	SpaceshipEventBus.resource_count_started.connect(_on_resource_count_started)

func _on_clicked():
	if StatsManager.day == 3:
		HandsEventBus.not_yet.emit()
		#PopUpSystem.show_text("Não.")
		return
	if not is_focused and clickable_highlight.is_mouse_over_area:
		change_to_focused()

func _on_focus_changed(focus: bool, subject: Node2D):
	## If there is a race condition with the activation of the clickable_highlight
	## here and the disabling of it on the ClickableHighlight module, we can work
	## around this problem having a state here that changes clickable_highlight.active
	## on process based off this state
	if focus == false:
		clickable_highlight.active = true
		clickable_highlight.is_mouse_over_area = false
		is_focused = false

	elif  focus == true and subject == self:
		is_focused = true
		activate_sub_areas()

func _on_resource_count_started(duration: float):
	shake_module.shake(self, duration * 1.5, 0.5)
