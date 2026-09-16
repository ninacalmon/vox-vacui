@abstract
class_name ActionExecutor
extends Node2D

enum States {FREE, BLOCKED}
var current_state: States

var main_spr: Sprite2D
var pcam: PhantomCamera2D
var energy_message: String = "Sem energia."

@abstract
func start()

@abstract
func finish()
