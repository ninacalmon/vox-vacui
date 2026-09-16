@abstract
class_name ActionExecutor
extends Node2D

signal was_freed

enum States {FREE, BLOCKED} 
var current_state: States = States.FREE

@export var main_spr: Sprite2D
@export var pcam: PhantomCamera2D
@export var energy_message: String = "Sem energia."

@abstract
func start()

@abstract
func finish()
