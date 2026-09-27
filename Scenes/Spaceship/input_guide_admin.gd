extends Node

@export var interaction_manager: InteractionManager

func _ready() -> void:
	SpaceshipEventBus.inter_acting.connect(_on_inter_acting)
	SpaceshipEventBus.inter_waiting.connect(_on_inter_waiting)
	InputGuide.clear_guides()
	show_default()


func show_default():
	InputGuide.show_guide(InputGuide.ActionType.INTERACT)
	InputGuide.show_guide(InputGuide.ActionType.CHANGE_ITEM)



func _on_inter_acting(inter: Interactable):
	InputGuide.clear_guides()

	for at in inter.action_type_array:
		InputGuide.show_guide(at)


func _on_inter_waiting():
	print("waiting")
	InputGuide.clear_guides()
	show_default()
