extends Button

var current_subject: MainArea

var can_operate: bool = true

func _ready() -> void:
	hide()

	SpaceshipEventBus.focus_changed.connect(_on_focus_mode_changed)
	pressed.connect(_on_button_pressed)

#func _process(_delta: float) -> void:
	#if current_subject:
		#can_operate =  current_subject.can_exit
#
	#if Input.is_action_just_pressed("return"):
		#if not can_operate:
			#return
		#if current_subject is ResourcesMachine:
			#SpaceshipEventBus.focus_off.emit(true)
		#else: SpaceshipEventBus.focus_off.emit()

func _on_focus_mode_changed(focus: bool, subject: Node2D):
	if focus == false:
		hide()
		return
	current_subject = subject
	show()

func _on_button_pressed():
	if not can_operate:
		return
	SpaceshipEventBus.focus_off.emit()
