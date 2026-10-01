extends GdUnitTestSuite

# The asteroid_small / asteroid_medium / asteroid_big .tscn scenes all share the
# same underlying script (res://scenes/modulars/asteroid.gd) but set different
# exported values on the root node. We test that script's exported defaults and
# the `calculate_damage_and_pieces` helper, which is fully deterministic.

const ASTEROID_SCRIPT := "res://scenes/asteroids/asteroid_body/asteroid.gd"


func _make() -> Asteroid:
	return load(ASTEROID_SCRIPT).new()


func test_script_extends_body_setup() -> void:
	var script := load(ASTEROID_SCRIPT)
	assert_that(script).is_not_null()
	# BodySetup extends RigidBody2D.
	assert_that(script.get_instance_base_type()).is_equal("RigidBody2D")


func test_default_exported_values() -> void:
	var a := _make()
	assert_that(a.asteroid_size).is_equal("small")
	assert_that(a.base_endurance).is_equal(200.0)
	assert_that(a.minimum_damage).is_equal(70.0)
	assert_that(a.minimum_external_damage).is_equal(160.0)
	assert_that(a.endur_to_pieces_proportion).is_equal(8.0)
	assert_that(a.critters_amount_min).is_equal(2)
	assert_that(a.critters_amount_max).is_equal(5)
	a.queue_free()


func test_state_defaults() -> void:
	var a := _make()
	assert_that(a.endurance).is_equal(0.0)
	assert_that(a.first_impact_bonus).is_equal(1.5)
	assert_that(a.parent).is_null()
	assert_that(a.chosen_palette).is_null()
	a.queue_free()


func test_calculate_damage_and_pieces_caps_at_endurance() -> void:
	var a := _make()
	a.base_endurance = 100.0
	a.endurance = 100.0
	# Damage larger than endurance: actual_damage should be clamped.
	var dict: Dictionary = a.calculate_damage_and_pieces(500.0, 1.0)
	assert_that(dict["actual_damage"]).is_equal(100.0)
	# pieces = ceil((100/8) * 1.0) = ceil(12.5) = 13.
	assert_that(dict["pieces"]).is_equal(13)
	a.queue_free()


func test_calculate_damage_and_pieces_with_bonus_multiplier() -> void:
	var a := _make()
	a.base_endurance = 100.0
	a.endurance = 100.0
	var dict: Dictionary = a.calculate_damage_and_pieces(80.0, 2.0)
	# actual_damage = min(80, 100) = 80.
	assert_that(dict["actual_damage"]).is_equal(80.0)
	# pieces = ceil((80/8) * 2.0) = ceil(20) = 20.
	assert_that(dict["pieces"]).is_equal(20)
	a.queue_free()


func test_calculate_damage_and_pieces_handles_zero_damage() -> void:
	var a := _make()
	a.base_endurance = 100.0
	a.endurance = 100.0
	var dict: Dictionary = a.calculate_damage_and_pieces(0.0, 1.0)
	assert_that(dict["actual_damage"]).is_equal(0.0)
	# pieces = ceil(0 * 1.0) = 0.
	assert_that(dict["pieces"]).is_equal(0)
	a.queue_free()


func test_asteroid_small_scene_has_small_size() -> void:
	var scene := load("res://scenes/asteroids/asteroid_body/asteroid_small.tscn") as PackedScene
	var a: Asteroid = scene.instantiate()
	add_child(a)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_that(a.asteroid_size).is_equal("small")
	# base_endurance set on the scene to 100.
	assert_that(a.base_endurance).is_equal(100.0)
	assert_that(a.endurance).is_equal(a.base_endurance)
	a.queue_free()


func test_asteroid_medium_scene_has_medium_size() -> void:
	var scene := load("res://scenes/asteroids/asteroid_body/asteroid_medium.tscn") as PackedScene
	var a: Asteroid = scene.instantiate()
	add_child(a)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_that(a.asteroid_size).is_equal("medium")
	a.queue_free()


func test_asteroid_big_scene_has_big_size() -> void:
	var scene := load("res://scenes/asteroids/asteroid_body/asteroid_big.tscn") as PackedScene
	var a: Asteroid = scene.instantiate()
	add_child(a)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_that(a.asteroid_size).is_equal("big")
	a.queue_free()
