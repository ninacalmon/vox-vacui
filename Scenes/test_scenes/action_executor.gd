class_name ActionExecutor
extends Node

enum States {BUSY, IDLE}

var highlight: bool
var current_state: States
var main_spr: Sprite2D
