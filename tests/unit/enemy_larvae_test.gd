extends GdUnitTestSuite

const EnemyLarvaeScript := preload("res://scenes/enemies/enemy_larvae.gd")
const PlayerScript := preload("res://scenes/player/player.gd")


func _make_player() -> Player:
	# Bare Player script instance; @onready vars are null but we don't access them.
	return PlayerScript.new()


func _make_larvae() -> EnemyLarvae:
	var e: EnemyLarvae = EnemyLarvaeScript.new()
	# Both @onready fields are null when not in tree; substitute stubs so that
	# internal calls to update_shader/flash don't crash on a Nil object.
	var aura := Sprite2D.new()
	e.set("explosion_aurea_sprite", aura)
	# mat is used in flash(); a fake ShaderMaterial with set_shader_parameter
	# stubbed. Skip setting mat — flash() guards with `if !mat`.
	return e


# ---------- Defaults ----------

func test_extends_rigid_body2d() -> void:
	var e: EnemyLarvae = EnemyLarvaeScript.new()
	assert_that(e).is_instanceof(RigidBody2D)
	e.free()


func test_default_state_is_chase() -> void:
	var e: EnemyLarvae = EnemyLarvaeScript.new()
	assert_that(e.state).is_equal(EnemyLarvae.State.CHASE)
	e.free()


func test_default_puff_timer_is_zero() -> void:
	var e: EnemyLarvae = EnemyLarvaeScript.new()
	assert_that(e.puff_timer).is_equal(0.0)
	e.free()


func test_default_player_inside_aggro_is_false() -> void:
	var e: EnemyLarvae = EnemyLarvaeScript.new()
	assert_that(e.player_inside_aggro).is_false()
	e.free()


func test_default_stun_time_is_6() -> void:
	var e: EnemyLarvae = EnemyLarvaeScript.new()
	assert_that(e.stun_time).is_equal(6.0)
	e.free()


func test_default_puff_speed_multiplier_is_0_2() -> void:
	var e: EnemyLarvae = EnemyLarvaeScript.new()
	assert_that(e.puff_speed_multiplier).is_equal(0.2)
	e.free()


func test_default_time_to_explode_is_3_5() -> void:
	var e: EnemyLarvae = EnemyLarvaeScript.new()
	assert_that(e.time_to_explode).is_equal(3.5)
	e.free()


func test_default_death_time_to_explode_is_1_5() -> void:
	var e: EnemyLarvae = EnemyLarvaeScript.new()
	assert_that(e.death_time_to_explode).is_equal(1.5)
	e.free()


func test_default_deflate_speed_multiplier_is_1_5() -> void:
	var e: EnemyLarvae = EnemyLarvaeScript.new()
	assert_that(e.deflate_speed_multiplier).is_equal(1.5)
	e.free()


func test_default_no_return_ratio_is_0_75() -> void:
	var e: EnemyLarvae = EnemyLarvaeScript.new()
	assert_that(e.no_return_ratio).is_equal(0.75)
	e.free()


# ---------- handle_puff ----------

func test_handle_puff_increases_puff_timer() -> void:
	var e: EnemyLarvae = _make_larvae()
	e.handle_puff(0.5)
	assert_that(e.puff_timer).is_equal(0.5)
	e.free()


func test_handle_puff_clamps_to_time_to_explode() -> void:
	var e: EnemyLarvae = _make_larvae()
	e.handle_puff(10.0)
	assert_that(e.puff_timer).is_equal(e.time_to_explode)
	e.free()


func test_handle_puff_transitions_to_committed_after_no_return_ratio() -> void:
	var e: EnemyLarvae = _make_larvae()
	# Use a known time_to_explode for determinism; bump it down so it's cheap.
	e.time_to_explode = 1.0
	e.no_return_ratio = 0.75
	# Delta above the commit threshold (0.75) but below the explode threshold (1.0).
	e.handle_puff(0.8)
	assert_that(e.state).is_equal(EnemyLarvae.State.EXPLOSION_COMMITTED)
	e.free()


func test_handle_puff_transitions_to_explode_at_full_time() -> void:
	var e: EnemyLarvae = _make_larvae()
	e.time_to_explode = 1.0
	e.no_return_ratio = 0.75
	e.handle_puff(1.5)
	assert_that(e.state).is_equal(EnemyLarvae.State.EXPLODE)
	e.free()


# ---------- handle_deflate ----------

func test_handle_deflate_decreases_puff_timer() -> void:
	var e: EnemyLarvae = _make_larvae()
	e.puff_timer = 1.0
	e.deflate_speed_multiplier = 1.0
	e.handle_deflate(0.5)
	assert_that(e.puff_timer).is_equal(0.5)
	e.free()


func test_handle_deflate_clamps_to_zero() -> void:
	var e: EnemyLarvae = _make_larvae()
	e.puff_timer = 0.3
	e.deflate_speed_multiplier = 1.0
	e.handle_deflate(1.0)
	assert_that(e.puff_timer).is_equal(0.0)
	e.free()


func test_handle_deflate_returns_to_chase_when_timer_hits_zero() -> void:
	var e: EnemyLarvae = _make_larvae()
	e.state = EnemyLarvae.State.DEFLATING
	e.puff_timer = 0.1
	e.deflate_speed_multiplier = 1.0
	# First call decrements and clamps to 0 (no transition yet).
	e.handle_deflate(0.5)
	# Second call: puff_timer is now 0, so the `else` branch fires and
	# transitions to CHASE.
	e.handle_deflate(0.001)
	assert_that(e.state).is_equal(EnemyLarvae.State.CHASE)
	e.free()


func test_handle_deflate_multiplier_applied() -> void:
	var e: EnemyLarvae = _make_larvae()
	e.puff_timer = 1.0
	e.deflate_speed_multiplier = 2.0
	e.handle_deflate(0.25)
	# 1.0 - (0.25 * 2.0) = 0.5
	assert_that(e.puff_timer).is_equal(0.5)
	e.free()


# ---------- update_shader ----------

func test_update_shader_sets_aurea_alpha_proportional_to_puff() -> void:
	var e: EnemyLarvae = _make_larvae()
	# explosion_aurea_sprite is already set to a Sprite2D in _make_larvae().
	e.puff_timer = 0.5
	e.time_to_explode = 1.0
	e.update_shader(1.0)
	# normalized_aurea = 0.5/1.0 = 0.5
	assert_that(e.explosion_aurea_sprite.modulate.a).is_equal(0.5)
	e.free()


# ---------- handle_explosion_death ----------

func test_handle_explosion_death_increments_puff_timer() -> void:
	var e: EnemyLarvae = _make_larvae()
	e.state = EnemyLarvae.State.EXPLOSION_DEATH
	e.puff_timer = 0.0
	e.time_to_explode = 1.0
	e.death_time_to_explode = 0.5
	e.handle_explosion_death(0.2)
	assert_that(e.puff_timer).is_equal(0.2)
	e.free()


func test_handle_explosion_death_transitions_to_explode() -> void:
	var e: EnemyLarvae = _make_larvae()
	e.state = EnemyLarvae.State.EXPLOSION_DEATH
	e.time_to_explode = 1.0
	e.death_time_to_explode = 0.5
	e.handle_explosion_death(0.6)
	assert_that(e.state).is_equal(EnemyLarvae.State.EXPLODE)
	e.free()


# ---------- Signal-based aggro handlers ----------

func test_aggro_entered_with_player_captures_and_transitions_to_inflating() -> void:
	var e: EnemyLarvae = _make_larvae()
	e.state = EnemyLarvae.State.CHASE
	var p := _make_player()
	e._on_aggro_entered(p)
	assert_that(e.player).is_equal(p)
	assert_that(e.player_inside_aggro).is_true()
	assert_that(e.state).is_equal(EnemyLarvae.State.INFLATING)
	p.free()
	e.free()


func test_aggro_entered_with_non_player_does_nothing() -> void:
	var e: EnemyLarvae = _make_larvae()
	e.state = EnemyLarvae.State.CHASE
	var other := Node2D.new()
	e._on_aggro_entered(other)
	assert_that(e.player_inside_aggro).is_false()
	assert_that(e.state).is_equal(EnemyLarvae.State.CHASE)
	other.free()
	e.free()


func test_aggro_exited_with_player_clears_inside_flag() -> void:
	var e: EnemyLarvae = _make_larvae()
	var p := _make_player()
	e.player = p
	e.player_inside_aggro = true
	e.state = EnemyLarvae.State.INFLATING
	e._on_aggro_exited(p)
	assert_that(e.player_inside_aggro).is_false()
	# state should have transitioned to DEFLATING (not committed).
	assert_that(e.state).is_equal(EnemyLarvae.State.DEFLATING)
	p.free()
	e.free()


func test_aggro_exited_does_not_deflate_when_committed() -> void:
	var e: EnemyLarvae = _make_larvae()
	var p := _make_player()
	e.player = p
	e.player_inside_aggro = true
	e.state = EnemyLarvae.State.EXPLOSION_COMMITTED
	e._on_aggro_exited(p)
	assert_that(e.state).is_equal(EnemyLarvae.State.EXPLOSION_COMMITTED)
	p.free()
	e.free()
