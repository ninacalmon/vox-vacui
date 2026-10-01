extends GdUnitTestSuite

const EnemyBasicScript := preload("res://scenes/enemies/enemy_basic.gd")
const PlayerScript := preload("res://scenes/player/player.gd")


func _make_player() -> Player:
	return PlayerScript.new()


# ---------- Defaults ----------

func test_extends_rigid_body2d() -> void:
	var e = EnemyBasicScript.new()
	assert_that(e).is_instanceof(RigidBody2D)
	e.free()


func test_default_state_is_wander() -> void:
	var e = EnemyBasicScript.new()
	# State enum lives on the script; access via the class itself.
	var state_val = e.get("state")
	assert_that(state_val).is_equal(0)  # WANDER is the first enum value.
	e.free()


func test_default_wander_direction_is_zero() -> void:
	var e = EnemyBasicScript.new()
	assert_that(e.wander_direction).is_equal(Vector2.ZERO)
	e.free()


func test_default_wander_timer_is_zero() -> void:
	var e = EnemyBasicScript.new()
	assert_that(e.wander_timer).is_equal(0.0)
	e.free()


func test_default_retreat_timer_is_zero() -> void:
	var e = EnemyBasicScript.new()
	assert_that(e.retreat_timer).is_equal(0.0)
	e.free()


# ---------- randomize_wander ----------

func test_randomize_wander_sets_a_non_zero_direction() -> void:
	var e = EnemyBasicScript.new()
	e.randomize_wander()
	assert_that(e.wander_direction.length()).is_greater(0.0)
	e.free()


func test_randomize_wander_sets_timer_within_expected_range() -> void:
	var e = EnemyBasicScript.new()
	e.randomize_wander()
	assert_that(e.wander_timer).is_greater_equal(1.0)
	assert_that(e.wander_timer).is_less_equal(3.0)
	e.free()


func test_randomize_wander_direction_is_normalized_when_nonzero() -> void:
	# Vector2.ZERO.normalized() returns Vector2.ZERO — a rare but theoretical
	# outcome if both randf_range calls hit 0. The existing "non-zero direction"
	# test above already covers the typical case; here we sample many draws and
	# confirm at least one is unit-length.
	var e = EnemyBasicScript.new()
	var found_unit := false
	for i in 50:
		e.randomize_wander()
		if is_equal_approx(e.wander_direction.length(), 1.0):
			found_unit = true
			break
	assert_that(found_unit).is_true()
	e.free()


# ---------- State transitions via signal handlers (public methods) ----------

func test_aggro_entered_with_player_transitions_to_chase() -> void:
	var e = EnemyBasicScript.new()
	# Use a real Player instance so the typed `player` property accepts it.
	var p := _make_player()
	# Assign the player so the `body == player` check inside the handler matches.
	e.player = p
	e._on_aggro_entered(p)
	# CHASE is the 2nd enum value (WANDER=0, CHASE=1, ATTACK=2, RETREAT=3).
	assert_that(e.get("state")).is_equal(1)
	p.free()
	e.free()


func test_aggro_entered_with_other_body_does_not_change_state() -> void:
	var e = EnemyBasicScript.new()
	e.set("state", 0)  # WANDER
	# player stays null so any body fails the `body == player` check.
	var other := Node2D.new()
	e._on_aggro_entered(other)
	assert_that(e.get("state")).is_equal(0)
	other.free()
	e.free()


func test_aggro_exited_with_player_transitions_to_wander() -> void:
	var e = EnemyBasicScript.new()
	var p := _make_player()
	# Assign player directly; the handler checks `body == player`.
	e.player = p
	e.set("state", 1)  # CHASE
	e._on_aggro_exited(p)
	assert_that(e.get("state")).is_equal(0)  # WANDER
	p.free()
	e.free()


func test_aggro_exited_with_other_body_does_not_change_state() -> void:
	var e = EnemyBasicScript.new()
	var p := _make_player()
	e.player = p
	e.set("state", 1)  # CHASE
	var other := Node2D.new()
	e._on_aggro_exited(other)
	assert_that(e.get("state")).is_equal(1)
	p.free()
	other.free()
	e.free()


# ---------- Inherited Enemy base values ----------

func test_inherited_speed_default_is_100() -> void:
	var e = EnemyBasicScript.new()
	assert_that(e.speed).is_equal(100.0)
	e.free()


func test_inherited_max_velocity_default_is_400() -> void:
	var e = EnemyBasicScript.new()
	assert_that(e.max_velocity).is_equal(400.0)
	e.free()


func test_inherited_life_default_is_4() -> void:
	var e = EnemyBasicScript.new()
	assert_that(e.life).is_equal(4.0)
	e.free()


func test_inherited_damage_default_is_3() -> void:
	var e = EnemyBasicScript.new()
	assert_that(e.damage).is_equal(3.0)
	e.free()


func test_inherited_wander_speed_default_is_30() -> void:
	var e = EnemyBasicScript.new()
	assert_that(e.wander_speed).is_equal(30.0)
	e.free()


func test_inherited_attack_force_default_is_800() -> void:
	var e = EnemyBasicScript.new()
	assert_that(e.attack_force).is_equal(800.0)
	e.free()


func test_inherited_attack_distance_default_is_80() -> void:
	var e = EnemyBasicScript.new()
	assert_that(e.attack_distance).is_equal(80.0)
	e.free()


func test_inherited_retreat_time_default_is_0_4() -> void:
	var e = EnemyBasicScript.new()
	assert_that(e.retreat_time).is_equal(0.4)
	e.free()
