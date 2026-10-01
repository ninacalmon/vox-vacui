extends GdUnitTestSuite

const GravityModuleScript := preload("res://scenes/modulars/gravity_module.gd")


func test_extends_node() -> void:
	var gm: Node = GravityModuleScript.new()
	assert_that(gm).is_instanceof(Node)
	gm.free()


func test_gravity_strength_default_is_980() -> void:
	var gm: GravityModule = GravityModuleScript.new()
	assert_that(gm.gravity_strength).is_equal(980.0)
	gm.free()


func test_gravity_direction_default_is_zero() -> void:
	var gm: GravityModule = GravityModuleScript.new()
	assert_that(gm.gravity_direction).is_equal(Vector2.ZERO)
	gm.free()


func test_target_default_is_null() -> void:
	var gm: GravityModule = GravityModuleScript.new()
	assert_that(gm.target).is_null()
	gm.free()


func test_set_gravity_normalizes_axis_aligned() -> void:
	var gm: GravityModule = GravityModuleScript.new()
	gm.set_gravity(Vector2(100, 0))
	assert_that(gm.gravity_direction).is_equal(Vector2(1, 0))
	gm.free()


func test_set_gravity_normalizes_negative_axis() -> void:
	var gm: GravityModule = GravityModuleScript.new()
	gm.set_gravity(Vector2(0, -250))
	assert_that(gm.gravity_direction).is_equal(Vector2(0, -1))
	gm.free()


func test_set_gravity_normalizes_diagonal_to_unit_length() -> void:
	var gm: GravityModule = GravityModuleScript.new()
	gm.set_gravity(Vector2(3, 4))
	# After normalization, length must be exactly 1.0.
	assert_that(gm.gravity_direction.length()).is_equal(1.0)
	gm.free()


func test_set_gravity_preserves_direction_sign() -> void:
	var gm: GravityModule = GravityModuleScript.new()
	gm.set_gravity(Vector2(-3, -4))
	assert_that(gm.gravity_direction.x).is_less(0.0)
	assert_that(gm.gravity_direction.y).is_less(0.0)
	assert_that(gm.gravity_direction.length()).is_equal(1.0)
	gm.free()


func test_gravity_strength_can_be_overridden() -> void:
	var gm: GravityModule = GravityModuleScript.new()
	gm.gravity_strength = 1234.5
	assert_that(gm.gravity_strength).is_equal(1234.5)
	gm.free()
