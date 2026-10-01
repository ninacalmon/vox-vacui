extends GdUnitTestSuite

const ResourceCollectorScript := preload("res://scenes/modulars/resource_collector.gd")


func test_extends_area2d() -> void:
	var collector: ResourceCollector = ResourceCollectorScript.new()
	assert_that(collector).is_instanceof(Area2D)
	collector.free()


func test_owner_body_default_is_null() -> void:
	var collector: ResourceCollector = ResourceCollectorScript.new()
	assert_that(collector.owner_body).is_null()
	collector.free()


func test_can_assign_owner_body() -> void:
	var collector: ResourceCollector = ResourceCollectorScript.new()
	var body := RigidBody2D.new()
	collector.owner_body = body
	assert_that(collector.owner_body).is_equal(body)
	body.free()
	collector.free()


func test_is_not_collectable_resource_by_default() -> void:
	# body_entered handler early-returns when body is not a CollectableResource.
	# This test confirms the type guard logic is reachable on the script side.
	var collector: ResourceCollector = ResourceCollectorScript.new()
	# A non-collectable body should not trigger side-effects (we can only check
	# that we never crash and that owner_body is still null afterwards).
	var fake_body := StaticBody2D.new()
	# Calling _on_body_entered with a non-CollectableResource should be a no-op.
	collector._on_body_entered(fake_body)
	assert_that(collector.owner_body).is_null()
	fake_body.free()
	collector.free()
