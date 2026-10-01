extends Node

@export var root_path: NodePath

@onready var sounds_list: Dictionary = {
	&"UI_Hover" : $HoverSFX,
	&"UI_Click" : $ClickSFX
}

func _ready() -> void:
	assert(root_path != null, "Empty root_path for UISounds!")

	install_sounds(get_node(root_path))

func install_sounds(node: Node):
	for i in node.get_children():
		if i is Button or i is TextureButton:
			i.focus_entered.connect(func(): ui_sfx_play(&"UI_Hover"))
			i.mouse_entered.connect(func(): ui_sfx_play(&"UI_Hover"))
			i.pressed.connect(func(): ui_sfx_play(&"UI_Click"))

		install_sounds(i)

func ui_sfx_play(sound: StringName):
	sounds_list[sound].play()
