extends Button

func _ready() -> void:
	if Globals.resources_gathered < Globals.resources_needed:
		grab_focus()
