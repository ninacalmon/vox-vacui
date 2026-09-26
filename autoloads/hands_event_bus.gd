extends Node

@warning_ignore("unused_signal")
signal machine_interaction

@warning_ignore("unused_signal")
signal monitor(state: bool)

@warning_ignore("unused_signal")
signal book(state: bool)

@warning_ignore("unused_signal")
signal page_prev

@warning_ignore("unused_signal")
signal page_next

@warning_ignore("unused_signal")
signal not_yet

var hand_is_busy: bool
