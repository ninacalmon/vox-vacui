extends GdUnitTestSuite

const SCRIPT_PATH := "res://scenes/bullets/boss_targeted_bullet.gd"


func _make() -> BossTargetedBullet:
	return load(SCRIPT_PATH).new()


func test_script_extends_boss_bullet() -> void:
	var script := load(SCRIPT_PATH)
	assert_that(script).is_not_null()
	# BossTargetedBullet extends BossBullet which extends Area2D.
	assert_that(script.get_instance_base_type()).is_equal("Area2D")


func test_default_exported_values() -> void:
	var b := _make()
	assert_that(b.turn_speed).is_equal(0.5)
	# Inherited from BossBullet
	assert_that(b.speed).is_equal(600.0)
	assert_that(b.damage).is_equal(1.0)
	assert_that(b.lifespan).is_equal(3.0)
	b.queue_free()


func test_target_defaults_to_null() -> void:
	var b := _make()
	assert_that(b.target).is_null()
	b.queue_free()


func test_direction_defaults_to_zero() -> void:
	var b := _make()
	assert_that(b.direction).is_equal(Vector2.ZERO)
	b.queue_free()


func test_body_entered_signal_fires_on_emit() -> void:
	var scene := load("res://scenes/bullets/boss_targeted_bullet.tscn") as PackedScene
	var b: BossTargetedBullet = scene.instantiate()
	add_child(b)
	await get_tree().process_frame

	var on_body := Callable(b, "_on_body_entered")
	if b.body_entered.is_connected(on_body):
		b.body_entered.disconnect(on_body)
	var fired := [false]
	b.body_entered.connect(func(_body: Node2D) -> void: fired[0] = true)
	var probe := Node2D.new()
	b.add_child(probe)
	b.body_entered.emit(probe)
	assert_that(fired[0]).is_true()

	b.queue_free()
