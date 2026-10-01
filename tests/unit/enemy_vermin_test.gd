extends GdUnitTestSuite

const EnemyVerminScript := preload("res://scenes/enemies/enemy_vermin.gd")
const PlayerScript := preload("res://scenes/player/player.gd")


func _make_player() -> Player:
	# Instantiate just to satisfy the `is Player` type check. The Player
	# script's @onready vars will be null but we never access them.
	return PlayerScript.new()


# ---------- Defaults ----------

func test_extends_rigid_body2d() -> void:
	var e: EnemyVermin = EnemyVerminScript.new()
	assert_that(e).is_instanceof(RigidBody2D)
	e.free()


func test_default_state_is_idle() -> void:
	var e: EnemyVermin = EnemyVerminScript.new()
	assert_that(e.state).is_equal(EnemyVermin.State.IDLE)
	e.free()


func test_default_can_attack_is_true() -> void:
	var e: EnemyVermin = EnemyVerminScript.new()
	assert_that(e.can_attack).is_true()
	e.free()


func test_default_chase_timer_is_zero() -> void:
	var e: EnemyVermin = EnemyVerminScript.new()
	assert_that(e.chase_timer).is_equal(0.0)
	e.free()


func test_default_stun_time_is_6() -> void:
	var e: EnemyVermin = EnemyVerminScript.new()
	assert_that(e.stun_time).is_equal(6.0)
	e.free()


func test_default_flee_speed_multiplier_is_1() -> void:
	var e: EnemyVermin = EnemyVerminScript.new()
	assert_that(e.flee_speed_multiplier).is_equal(1.0)
	e.free()


func test_default_safe_distance_is_180() -> void:
	var e: EnemyVermin = EnemyVerminScript.new()
	assert_that(e.safe_distance).is_equal(180.0)
	e.free()


func test_default_fleeing_time_is_vector_one_one_five() -> void:
	var e: EnemyVermin = EnemyVerminScript.new()
	assert_that(e.fleeing_time).is_equal(Vector2(1, 1.5))
	e.free()


# ---------- start_flee_timer ----------

func test_start_flee_timer_sets_chase_timer_within_range() -> void:
	var e: EnemyVermin = EnemyVerminScript.new()
	e.start_flee_timer()
	# fleeing_time is Vector2(1, 1.5), so chase_timer must land in [1.0, 1.5].
	assert_that(e.chase_timer).is_greater_equal(e.fleeing_time.x)
	assert_that(e.chase_timer).is_less_equal(e.fleeing_time.y)
	e.free()


func test_start_flee_timer_overwrites_previous_chase_timer() -> void:
	var e: EnemyVermin = EnemyVerminScript.new()
	e.chase_timer = 999.0
	e.start_flee_timer()
	assert_that(e.chase_timer).is_less(999.0)
	e.free()


# ---------- perform_attack ----------
# NOTE: perform_attack calls player.apply_stun(...) and player.take_damage(...)
# which in turn depend on the Player's @onready sub-modules. Testing it
# deterministically requires a fully-constructed Player scene, so we skip it
# here (left intentionally rather than leaving a flaky test).

# ---------- Signal-based aggro handler ----------

func test_aggro_entered_with_player_from_idle_starts_flee_and_captures_player() -> void:
	var e: EnemyVermin = EnemyVerminScript.new()
	e.state = EnemyVermin.State.IDLE
	var p := _make_player()
	e._on_aggro_entered(p)
	assert_that(e.state).is_equal(EnemyVermin.State.FLEE)
	assert_that(e.player).is_equal(p)
	assert_that(e.chase_timer).is_greater(0.0)
	p.free()
	e.free()


func test_aggro_entered_with_non_player_does_nothing() -> void:
	var e: EnemyVermin = EnemyVerminScript.new()
	e.state = EnemyVermin.State.IDLE
	var other := Node2D.new()
	e._on_aggro_entered(other)
	assert_that(e.state).is_equal(EnemyVermin.State.IDLE)
	other.free()
	e.free()


func test_aggro_entered_in_non_idle_state_does_not_change_state() -> void:
	var e: EnemyVermin = EnemyVerminScript.new()
	e.state = EnemyVermin.State.CHASE
	var p := _make_player()
	e._on_aggro_entered(p)
	# Should not transition to FLEE because state was not IDLE.
	assert_that(e.state).is_equal(EnemyVermin.State.CHASE)
	p.free()
	e.free()


# ---------- Inherited Enemy base values ----------

func test_inherited_speed_default_is_100() -> void:
	var e: EnemyVermin = EnemyVerminScript.new()
	assert_that(e.speed).is_equal(100.0)
	e.free()


func test_inherited_attack_distance_default_is_80() -> void:
	var e: EnemyVermin = EnemyVerminScript.new()
	assert_that(e.attack_distance).is_equal(80.0)
	e.free()


func test_inherited_max_velocity_default_is_400() -> void:
	var e: EnemyVermin = EnemyVerminScript.new()
	assert_that(e.max_velocity).is_equal(400.0)
	e.free()
