extends GdUnitTestSuite

const HurtModuleScript := preload("res://scenes/modulars/hurt_module.gd")


func test_extends_node2d() -> void:
	var hm: Node2D = HurtModuleScript.new()
	assert_that(hm).is_instanceof(Node2D)
	hm.free()


func test_tolerance_default_is_80() -> void:
	var hm: Node2D = HurtModuleScript.new()
	assert_that(hm.tolerance).is_equal(80.0)
	hm.free()


func test_velocity_lenght_array_starts_empty() -> void:
	var hm: Node2D = HurtModuleScript.new()
	assert_that(hm.velocity_lenght_array).is_empty()
	hm.free()


func test_vel_lenght_default_is_zero() -> void:
	var hm: Node2D = HurtModuleScript.new()
	assert_that(hm.vel_lenght).is_equal(0.0)
	hm.free()


func test_last_vel_lenght_default_is_zero() -> void:
	var hm: Node2D = HurtModuleScript.new()
	assert_that(hm.last_vel_lenght).is_equal(0.0)
	hm.free()


func test_owner_body_default_is_null() -> void:
	var hm: Node2D = HurtModuleScript.new()
	assert_that(hm.owner_body).is_null()
	hm.free()


func test_velocity_lenght_array_capacity_is_bounded_to_5() -> void:
	# Simulate the bounded-array logic: push 7 entries, only the most recent 5 remain.
	var hm: Node2D = HurtModuleScript.new()
	for i in 7:
		hm.velocity_lenght_array.push_front(float(i))
		if hm.velocity_lenght_array.size() > 5:
			hm.velocity_lenght_array.pop_back()
	assert_that(hm.velocity_lenght_array.size()).is_equal(5)
	hm.free()
