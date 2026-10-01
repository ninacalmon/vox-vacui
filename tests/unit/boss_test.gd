extends GdUnitTestSuite

const BossScript := preload("res://scenes/enemies/boss.gd")
const PlayerScript := preload("res://scenes/player/player.gd")


func _make_player() -> Player:
	# Bare Player script instance; @onready vars are null but we don't access them.
	return PlayerScript.new()


func _make_boss() -> Boss:
	var b: Boss = BossScript.new()
	# mat is @onready and null when not in tree; flash() checks `if !mat`,
	# but call_deferred("die") in _on_damage_taken runs die() which writes to
	# sprite_2d. We only test state transitions that don't reach die().
	return b


# ---------- Defaults ----------

func test_extends_rigid_body2d() -> void:
	var b: Boss = BossScript.new()
	assert_that(b).is_instanceof(RigidBody2D)
	b.free()


func test_default_state_is_idle() -> void:
	var b: Boss = BossScript.new()
	assert_that(b.current_state).is_equal(Boss.State.IDLE)
	b.free()


func test_default_is_dead_is_false() -> void:
	var b: Boss = BossScript.new()
	assert_that(b.is_dead).is_false()
	b.free()


func test_default_is_attacking_now_is_false() -> void:
	var b: Boss = BossScript.new()
	assert_that(b.is_attacking_now).is_false()
	b.free()


func test_default_attack_offset_is_zero() -> void:
	var b: Boss = BossScript.new()
	assert_that(b.attack_offset).is_equal(0.0)
	b.free()


func test_default_float_tween_is_null() -> void:
	var b: Boss = BossScript.new()
	assert_that(b.float_tween).is_null()
	b.free()


func test_default_player_is_null() -> void:
	var b: Boss = BossScript.new()
	assert_that(b.player).is_null()
	b.free()


func test_default_life_is_100() -> void:
	var b: Boss = BossScript.new()
	assert_that(b.life).is_equal(100.0)
	b.free()


func test_default_bullet_count_is_24() -> void:
	var b: Boss = BossScript.new()
	assert_that(b.bullet_count).is_equal(24)
	b.free()


func test_default_attack_wait_time_is_4() -> void:
	var b: Boss = BossScript.new()
	assert_that(b.attack_wait_time).is_equal(4.0)
	b.free()


func test_default_special_attack_wait_time_min_is_8() -> void:
	var b: Boss = BossScript.new()
	assert_that(b.special_attack_wait_time_min).is_equal(8.0)
	b.free()


func test_default_special_attack_wait_time_max_is_15() -> void:
	var b: Boss = BossScript.new()
	assert_that(b.special_attack_wait_time_max).is_equal(15.0)
	b.free()


func test_default_projectile_time_offset_is_0_05() -> void:
	var b: Boss = BossScript.new()
	assert_that(b.projectile_time_offset).is_equal(0.05)
	b.free()


func test_default_attack_offset_change_is_0_5() -> void:
	var b: Boss = BossScript.new()
	assert_that(b.attack_offset_change).is_equal(0.5)
	b.free()


func test_default_deactivate_is_true() -> void:
	var b: Boss = BossScript.new()
	assert_that(b.deactivate).is_true()
	b.free()


# ---------- activate ----------

func test_activate_sets_deactivate_to_false() -> void:
	var b: Boss = BossScript.new()
	b.activate()
	assert_that(b.deactivate).is_false()
	b.free()


# ---------- _on_aggro_area_entered ----------

func test_aggro_area_entered_with_player_when_active_starts_attacking() -> void:
	var b: Boss = _make_boss()
	b.deactivate = false
	var p := _make_player()
	b._on_aggro_area_entered(p)
	assert_that(b.player).is_equal(p)
	assert_that(b.current_state).is_equal(Boss.State.ATTACKING)
	p.free()
	b.free()


func test_aggro_area_entered_with_player_when_deactivated_does_nothing() -> void:
	var b: Boss = _make_boss()
	b.deactivate = true
	var p := _make_player()
	b._on_aggro_area_entered(p)
	assert_that(b.player).is_null()
	assert_that(b.current_state).is_equal(Boss.State.IDLE)
	p.free()
	b.free()


func test_aggro_area_entered_with_player_when_dead_does_nothing() -> void:
	var b: Boss = _make_boss()
	b.deactivate = false
	b.is_dead = true
	var p := _make_player()
	b._on_aggro_area_entered(p)
	assert_that(b.player).is_null()
	assert_that(b.current_state).is_equal(Boss.State.IDLE)
	p.free()
	b.free()


func test_aggro_area_entered_with_non_player_does_nothing() -> void:
	var b: Boss = _make_boss()
	b.deactivate = false
	# The handler signature is `body: PhysicsBody2D`, so use a StaticBody2D.
	var other := StaticBody2D.new()
	b._on_aggro_area_entered(other)
	assert_that(b.player).is_null()
	assert_that(b.current_state).is_equal(Boss.State.IDLE)
	other.free()
	b.free()


# ---------- _on_damage_taken ----------

func test_damage_taken_when_active_subtracts_life() -> void:
	var b: Boss = _make_boss()
	b.deactivate = false
	b.life = 50.0
	b._on_damage_taken(10.0, null)
	assert_that(b.life).is_equal(40.0)
	b.free()


func test_damage_taken_when_deactivated_does_not_subtract_life() -> void:
	var b: Boss = _make_boss()
	b.deactivate = true
	b.life = 50.0
	b._on_damage_taken(10.0, null)
	assert_that(b.life).is_equal(50.0)
	b.free()


func test_damage_taken_when_dead_does_not_subtract_life() -> void:
	var b: Boss = _make_boss()
	b.deactivate = false
	b.is_dead = true
	b.life = 50.0
	b._on_damage_taken(10.0, null)
	assert_that(b.life).is_equal(50.0)
	b.free()


# NOTE: Testing damage that triggers die() is intentionally skipped.
# die() touches many @onready nodes (sprite_2d, sprite_2d_dead_head,
# collision_polygon_2d, hook) which are null outside the scene tree and
# would crash. The state transition itself is covered by the in-scene
# battle loop.
