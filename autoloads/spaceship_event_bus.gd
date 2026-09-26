extends Node

@warning_ignore("unused_signal")
signal focus_on(zoom_in_amount: float, zoom_offset: Vector2, emitter: Node2D, keep_camera: bool)

@warning_ignore("unused_signal")
signal focus_off(reset_to_center_room: bool)

@warning_ignore("unused_signal")
signal resource_count_finished

@warning_ignore("unused_signal")
signal resource_count_started(duration: float)

@warning_ignore("unused_signal")
signal focus_changed(focus: bool, subject: Node2D)

@warning_ignore("unused_signal")
signal resources_spent

@warning_ignore("unused_signal")
signal player_going_out


@warning_ignore("unused_signal")
signal snap_ui_left
@warning_ignore("unused_signal")
signal snap_ui_right
