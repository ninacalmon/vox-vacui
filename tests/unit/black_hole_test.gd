extends GdUnitTestSuite

# Tests for res://scenes/black_hole/black_hole.gd
# All real physics-driven behavior (gravitational field body entered/exited,
# SFXManager.play_sound in _process) is left untested; it relies on the full
# scene tree, signals from physics simulation, and the SFXManager autoload.

const BLACK_HOLE_SCRIPT := "res://scenes/black_hole/black_hole.gd"
const BLACK_HOLE_SCENE := "res://scenes/black_hole/black_hole.tscn"


func _make() -> BlackHole:
	return load(BLACK_HOLE_SCRIPT).new()


func test_script_extends_body_setup() -> void:
	var script := load(BLACK_HOLE_SCRIPT)
	assert_that(script).is_not_null()
	# BodySetup extends RigidBody2D.
	assert_that(script.get_instance_base_type()).is_equal("RigidBody2D")


func test_state_defaults() -> void:
	var b := _make()
	assert_that(b.is_body_close).is_equal(false)
	assert_that(b.check_distance).is_equal(false)
	assert_that(b.player).is_null()
	b.queue_free()


func test_gulp_sfx_node_exists_in_scene() -> void:
	var scene := load(BLACK_HOLE_SCENE) as PackedScene
	var b: BlackHole = scene.instantiate()
	add_child(b)
	await get_tree().process_frame
	await get_tree().process_frame

	assert_that(b.gulp_sfx).is_not_null()
	assert_that(b.gulp_sfx).is_instanceof(AudioStreamPlayer)
	# Volume_db and bus from the scene file.
	assert_that(b.gulp_sfx.volume_db).is_equal(-14.0)
	assert_that(b.gulp_sfx.bus).is_equal("Sound Effects")

	b.queue_free()


func test_gravitational_field_node_exists_in_scene() -> void:
	var scene := load(BLACK_HOLE_SCENE) as PackedScene
	var b: BlackHole = scene.instantiate()
	add_child(b)
	await get_tree().process_frame

	assert_that(b.gravitational_field).is_not_null()

	b.queue_free()
