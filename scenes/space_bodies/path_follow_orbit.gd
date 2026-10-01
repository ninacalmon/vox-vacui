class_name PathFollowOrbit
extends PathFollow2D

var speed: float = 50

var reverse: bool

func _process(delta: float) -> void:
	if reverse:
		progress -= delta * speed
	else: progress += delta * speed
