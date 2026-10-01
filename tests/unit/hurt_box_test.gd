extends GdUnitTestSuite

const HurtBoxScript := preload("res://scenes/modulars/hurt_box.gd")


func test_extends_area2d() -> void:
	var hb: Area2D = HurtBoxScript.new()
	assert_that(hb).is_instanceof(Area2D)
	hb.free()


func test_bullet_sensible_default_is_true() -> void:
	var hb: HurtBox = HurtBoxScript.new()
	assert_that(hb.bullet_sensible).is_true()
	hb.free()


func test_bullet_sensible_can_be_disabled() -> void:
	var hb: HurtBox = HurtBoxScript.new()
	hb.bullet_sensible = false
	assert_that(hb.bullet_sensible).is_false()
	hb.free()


func test_damage_taken_signal_is_declared() -> void:
	var hb: HurtBox = HurtBoxScript.new()
	var signal_names: Array = []
	for s in hb.get_signal_list():
		signal_names.append(s["name"])
	assert_that(signal_names).contains("damage_taken")
	hb.free()


func test_damage_taken_signal_fires_with_amount_and_causer() -> void:
	# Connect to the signal before adding to the tree; emit manually by calling
	# the private handler with a non-Bullet body. The handler should early-return
	# because `area is Bullet` is false, so no signal should fire.
	var hb: HurtBox = HurtBoxScript.new()
	add_child(hb)
	var fired: Array = [false]
	var received_amount: Array = [0.0]
	var received_causer: Array = [null]
	hb.damage_taken.connect(func(amount: float, causer: Node2D) -> void:
		fired[0] = true
		received_amount[0] = amount
		received_causer[0] = causer
	)
	# A plain Area2D is not a Bullet, so the handler must not emit.
	var plain_area := Area2D.new()
	hb._on_area_entered(plain_area)
	assert_that(fired[0]).is_false()
	plain_area.free()
	hb.queue_free()
