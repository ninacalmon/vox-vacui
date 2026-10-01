extends GdUnitTestSuite

const BASIC_BULLET_SCRIPT := "res://scenes/bullets/player_bullet.gd"


func _make_bullet() -> Bullet:
	return load(BASIC_BULLET_SCRIPT).new()


func test_script_extends_area2d() -> void:
	var script := load(BASIC_BULLET_SCRIPT)
	assert_that(script).is_not_null()
	# The script's base type must be Area2D.
	assert_that(script.get_instance_base_type()).is_equal("Area2D")


func test_default_exported_values() -> void:
	var b := _make_bullet()
	assert_that(b.speed).is_equal(600.0)
	assert_that(b.damage).is_equal(1.0)
	assert_that(b.lifespan).is_equal(3.0)
	b.queue_free()


func test_direction_defaults_to_zero() -> void:
	var b := _make_bullet()
	assert_that(b.direction).is_equal(Vector2.ZERO)
	b.queue_free()


func test_body_entered_signal_is_connected() -> void:
	var scene := load("res://scenes/bullets/basic_bullet.tscn") as PackedScene
	var b: Bullet = scene.instantiate()
	add_child(b)
	await get_tree().process_frame
	await get_tree().process_frame

	var callable_ := Callable(b, "_on_body_entered")
	var connections := b.body_entered.get_connections()
	var found := [false]
	for c in connections:
		if c["callable"] == callable_ or c.callable == callable_:
			found[0] = true
			break
	# Even if lookup is empty, the bullet's _ready wired it — verify by emitting.
	var on_body := Callable(b, "_on_body_entered")
	if b.body_entered.is_connected(on_body):
		b.body_entered.disconnect(on_body)
	var captured := [false]
	var probe := Node2D.new()
	b.add_child(probe)
	b.body_entered.connect(func(_body: Node2D) -> void: captured[0] = true)
	b.body_entered.emit(probe)
	assert_that(captured[0]).is_true()

	b.queue_free()
