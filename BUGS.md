# BUGS.md — Known logic bugs (left untouched by the cleaning pass)

> **Scope:** real behavioral bugs in the current `RogueSpace-main` (vox vacui, Godot 4.5) code that
> the code‑cleaning pass (phases 0–5 of `CLEANING_PLAN.md`) intentionally did **not** fix, because it
> only touched formatting/ordering/dead‑code. Each item below was re‑verified by reading the current
> source after the cleaning pass. Nothing here has been changed — this is a bug inventory only.
>
> **Severity key:**
> - **HIGH** — reachable in normal play, breaks progression or objective logic.
> - **MED** — reachable runtime error or wrong gameplay value.
> - **LOW** — cosmetic / minor wrong behavior.
> - **DEAD** — code path cannot execute in current scenes, but would crash/misbehave if wired up.

---

## Summary table

| ID | Severity | Location | One-liner |
|----|----------|----------|-----------|
| BUG‑01 | HIGH | `scenes/spaceship/mothership_enter_area.gd:41,66` + `scenes/spaceship/door_closed.gd:17` | Day 3 can be finished **without** the Matriarch corpse (boss fight skippable) |
| BUG‑02 | HIGH | `scenes/enemies/matriarch_hook.gd:68` | `player_has_cadaver` set on *any* input near the boss, before the rope is tied |
| BUG‑03 | MED | `scenes/spaceship/resources_deposit.gd:36` + `autoloads/globals.gd:36,46` | Deposited resources are refunded on Continue — advancing a day costs nothing |
| BUG‑04 | MED | `scenes/player/player.gd:220‑228` | `apply_stun` reuses a finished `Tween` → runtime error every stun |
| BUG‑05 | MED | `scenes/modulars/hurt_module.gd:37` | Out‑of‑bounds `get(1)` on first contact → script error, damage lost |
| BUG‑06 | LOW | `scenes/enemies/enemy_vermin.gd:51‑78` | `_integrate_forces` dereferences `player` with no validity guard |
| BUG‑07 | DEAD | `scenes/modulars/black_hole_gravitational_field.gd:62‑68` | "Event horizon" handler is a no‑op (returns for every valid body) |
| BUG‑08 | DEAD | `scenes/modulars/map_generator.gd:30‑32,88‑91` | Generates nothing: `add_child` commented out, tile still erased; medium preloads the *small* asteroid |
| BUG‑09 | DEAD | `scenes/ui/resources_counter_texts.gd`, `scenes/ui/button.gd` (orphan `resources_counting.tscn`) | Reference `Globals.resources_gathered/needed/level` which no longer exist → crash on load |
| BUG‑10 | DEAD | `scenes/ui/power_ups_manager.gd:9,15,17` | References nonexistent `PowerUps.queued_power_ups_array`, `Globals.player_burst_speed`, `ProgressBar.max_fuel` |
| BUG‑11 | LOW | `scenes/player/player.gd:169` | Dash at rest does nothing but still consumes fuel + cooldown; direction locked to velocity, not input |
| BUG‑12 | LOW | `scenes/ui/indicator.gd:19,60‑71` | `was_visible_on_screen` never updated → indicator always hard‑snaps, smoothing branch dead |
| BUG‑13 | LOW | `scenes/black_hole/black_hole.gd:23‑27` | Gulp SFX re‑played every frame while player is close (overlapping sound spam) |

---

## Detailed findings

### BUG‑01 — Day 3 can be finished without the Matriarch's body (HIGH)

The final objective ("bring the Matriarch's corpse") is informational only — nothing enforces it.

- `mothership_enter_area.gd:41` — entry gate only checks resources:
  ```gdscript
  if StatsManager.current_resources < StatsManager.resources_needed:
  ```
  On day 3 `Globals.update_resources_goal()` sets `StatsManager.resources_needed = 0`
  (`autoloads/globals.gd:61`), so the gate **always passes**. The corpse is mentioned only as a
  popup at `mothership_enter_area.gd:66‑67`:
  ```gdscript
  if StatsManager.day == 3 and not StatsManager.player_has_cadaver:
      PopUpSystem.show_text("Traga o corpo d'A Matriarca.", 5)
  ```
- `door_closed.gd:17‑19` — the ship's closed door jumps to the finale on day 3 with **no** corpse check:
  ```gdscript
  else:
      Globals.next_scene_path = "res://scenes/cutscenes/cutscene_final2.tscn"
      LevelTransition.change_scene_to("res://scenes/cutscenes/cutscene_final.tscn")
  ```
  (`next_scene_path` is then consumed by `cutscene.gd:64`, so the chaining is intentional — only the
  missing corpse gate is the bug.)

**Impact:** on day 3 the player can walk into the ship (0 resources required), click the closed
door, and reach the ending without ever fighting/towing the Matriarch. The boss fight and towing
mechanic are entirely skippable.

**Fix direction:** block the entrance (`mothership_enter_area.gd:41`) and/or the door
(`door_closed.gd:13`) when `StatsManager.day == 3 and not StatsManager.player_has_cadaver`.

---

### BUG‑02 — `player_has_cadaver` is set without tying the rope (HIGH)

`scenes/enemies/matriarch_hook.gd:65‑70`:
```gdscript
if is_player_inside() and not connected:
    if event.is_action_pressed("confirm"):
        connected = true
    StatsManager.player_has_cadaver = true   # <-- line 68: OUTSIDE the confirm gate
    PopUpSystem.show_text("Confirme para amarrar sua corda n'A Matriarca.", 3.0)
    EventBus.boss_in_capture_area.emit(true)
```

`_input` fires on **every** input event. As soon as the player is inside the capture area (before
pressing confirm, and even if the rope is never tied), *any* input — moving, shooting, etc. — sets
`StatsManager.player_has_cadaver = true` for the rest of the game. Consequences:

1. It feeds BUG‑01: the day‑3 "have the corpse" flag is satisfied trivially.
2. `player.gd:110‑111` `execute_teletransport()` short‑circuits permanently once the flag is set,
   so the out‑of‑bounds rescue teleport stops working for the whole of day 3:
   ```gdscript
   func execute_teletransport():
       if StatsManager.player_has_cadaver:
           return
   ```
3. The popup + `boss_in_capture_area.emit(true)` re‑fire on every input event while inside.

**Fix direction:** move `StatsManager.player_has_cadaver = true` (and the popup/emit) inside the
`if event.is_action_pressed("confirm")` branch so it only happens after the rope is actually tied.

---

### BUG‑03 — Deposited resources are refunded on Continue — progression is free (MED)

Deposit path:
- `scenes/spaceship/resources_deposit.gd:36‑38`:
  ```gdscript
  StatsManager.current_resources -= StatsManager.resources_needed
  SpaceshipEventBus.resources_spent.emit()
  Globals.has_energy_in_spaceship = true
  ```
- `autoloads/globals.gd:33‑39` — the `has_energy_in_spaceship` setter banks the exact amount back
  into `fragments_value_to_sum`:
  ```gdscript
  set (value):
      if value == true:
          fragments_value_to_sum = StatsManager.resources_needed
          has_energy_in_spaceship = false
  ```
- Menu Continue — `scenes/levels/menus/menu_buttons_control.gd` `_on_continue_pressed` calls
  `Globals.add_frag_sum()` (`globals.gd:45‑46`):
  ```gdscript
  StatsManager.current_resources += fragments_value_to_sum
  ```

**Impact:** deduction at deposit (`−resources_needed`) is exactly offset by the refund on Continue
(`+resources_needed`). Advancing a day costs **zero** net resources; the only real drains are
power‑up purchases and death (`player_died()` zeroes `current_resources`). Whether this is intended
carry‑over or an exploit needs a design decision.

Secondary issue: `Globals.reset_game_state()` (`globals.gd:63‑70`) never resets
`fragments_value_to_sum`, so a stale banked value survives resets/new‑game starts.

---

### BUG‑04 — `apply_stun` reuses a finished Tween → runtime error every stun (MED)

`scenes/player/player.gd:212‑229`:
```gdscript
func apply_stun(stun_duration: float):
    ...
    var tween = create_tween()
    tween.tween_property(sprite_stun, "modulate:a", 1, 0.3)
    await get_tree().create_timer(stun_duration).timeout   # e.g. 6 s
    ...
    tween.tween_property(sprite_stun, "modulate:a", 0, 0.3)   # tween finished & killed ~5.7 s ago
```

The first property tween finishes after 0.3 s and Godot auto‑kills a finished non‑looping tween.
Calling `tween_property` on it later logs
`ERROR: Tween invalid. Either finished or created outside scene tree.` and returns `null` — the
fade‑out never plays (the stun sprite just vanishes via the following `sprite_stun.hide()`). This
triggers on **every** successful vermin/larva stun (stun_time = 6 s).

**Fix direction:** create a fresh tween after the `await` (like `execute_teletransport` does at
`player.gd:123`).

---

### BUG‑05 — `hurt_module` out‑of‑bounds read on first contact (MED)

`scenes/modulars/hurt_module.gd:31‑40`:
```gdscript
func _on_owner_body_shape_entered(_body: RigidBody2D):
    vel_lenght = owner_body.linear_velocity.length()
    velocity_lenght_array.push_front(vel_lenght)
    ...
    if abs(velocity_lenght_array.get(1) - velocity_lenght_array.get(0)) >= tolerance:
```

If a `body_entered` fires before `_physics_process` has pushed at least one prior sample (e.g.
bodies overlapping at spawn in the same physics tick), the array holds a single entry and
`get(1)` returns `null`; `null - Float` throws
`SCRIPT ERROR: Invalid operands 'Nil' and 'float' in operator '-'`. The collision handler aborts, so
the first impact damage is silently lost. (Edge‑case timing, hence MED/RISK rather than always‑on.)

**Fix direction:** guard on `velocity_lenght_array.size() >= 2` before indexing `get(1)`.

---

### BUG‑06 — `enemy_vermin._integrate_forces` dereferences a freed player (LOW)

`scenes/enemies/enemy_vermin.gd:51‑78` uses `player.global_position` / `player.apply_stun` /
`player.take_damage` with **no** `is_instance_valid(player)` guard — unlike `_process` which guards
at line 31. If the player is freed mid‑chase (scene teardown frame), this is a null‑deref script
error. Low reachability, but the asymmetry is a latent crash.

---

### BUG‑07 — Black‑hole "event horizon" handler is a no‑op (DEAD)

`scenes/modulars/black_hole_gravitational_field.gd:62‑68`:
```gdscript
func _on_event_horizon_entered(area: GravitationalField):
    var body = area.owner_body
    if body == owner_body:
        return
    if is_instance_valid(body):
        return
```

`is_instance_valid(body)` is true for every live body, so the handler always returns — the
"point of no return" (comment at line 13) does nothing. There is no destroy/suck behavior. The
signal is connected at line 20, but the entire handler is dead.

**Impact:** if the event horizon was meant to consume bodies (as the name/comment imply), it never
does. The gravitational pull (`apply_gravity`) is separate and works.

---

### BUG‑08 — `map_generator` spawns nothing, and mis-preloads the medium asteroid (DEAD)

`scenes/modulars/map_generator.gd`:
- `30‑32` — copy‑paste error: "medium" preload points at the **small** asteroid scene:
  ```gdscript
  @onready var medium_asteroid_scene = preload(
          "res://scenes/asteroids/asteroid_body/asteroid_small.tscn"
      )
  ```
- `88‑91` — `add_child` is commented out, yet the tile is still erased:
  ```gdscript
  #add_child(asteroid)
  # remove the tile
  tile_map_layer_asteroids.set_cell(cell, -1)
  ```

**Impact:** if this generator were used it would (a) instantiate asteroids into nothing, (b) erase
every tile, producing an empty map, and (c) spawn small asteroids where mediums are intended.
Reachability: current level scenes use `tile_map_generator.gd` (same `MapGenerator` node type);
`map_generator.tscn` is never instanced (only the script is referenced by a unit test), so this is
latent. Fix if it is ever intended to be live.

---

### BUG‑09 — Orphaned `resources_counting.tscn` would crash on load (DEAD)

`scenes/levels/spaceship_interior/resources_counting.tscn` is the **only** scene referencing:
- `scenes/ui/resources_counter_texts.gd` (`class_name TextsControl`) — uses
  `Globals.resources_gathered` (lines 24, 39, 45, 83), `Globals.resources_needed` (24, 30, 66) and
  `Globals.level += 1` (line 75) / `Globals.level` in scene paths (77, 80).
- `scenes/ui/button.gd` — `_ready()`: `if Globals.resources_gathered < Globals.resources_needed`.

None of `Globals.level` / `Globals.resources_gathered` / `Globals.resources_needed` exist in
`autoloads/globals.gd` — they were **commented out in commit `ca47ad9`** ("refactor: code
standardization v1") while these scripts kept their references. Loading the scene would error at
`_ready()`.

`resources_counting.tscn` is referenced by nothing else in the project (it was superseded by the
in‑interior `Monitor.tscn` / `resource_counter.gd` flow). Either delete it (and the two scripts) or
restore the missing `Globals` members and rewire — currently it is a latent crash.

---

### BUG‑10 — `power_ups_manager.gd` references nonexistent members (DEAD)

`scenes/ui/power_ups_manager.gd`:
- line 9: `PowerUps.queued_power_ups_array` — does not exist in `autoloads/power_ups.gd`.
- line 15: `Globals.player_burst_speed` — does not exist in `autoloads/globals.gd`.
- line 17: `fuel_progress.max_fuel` — `ProgressBar` has `max_value`, not `max_fuel`.

The script is never instanced in any scene, so it cannot crash today, but it is broken if wired up.
The live power‑up flow is `power_ups_container.gd` + `power_up_setup.gd` (see `Monitor.tscn`).

---

### BUG‑11 — Dash at rest does nothing but still consumes fuel + cooldown (LOW)

`scenes/player/player.gd:163‑170`:
```gdscript
func impulse_burst(state):
    if Input.is_action_just_pressed("impulse_burst"):
        if impulse_cooldown_timer <= 0:
            SFXManager.play_sound(dash_sfx)
            impulse_cooldown_timer = StatsManager.player_impulse_cooldown_duration
            update_fuel(true)
            state.apply_impulse(linear_velocity.normalized() * impulse_speed)   # line 169
```

When the player is at rest, `linear_velocity.normalized()` is `Vector2.ZERO`, so the impulse is a
no‑op — but fuel is still spent (`update_fuel(true)`, `FUEL_IMPULSE_USE_STEP`) and the 3 s cooldown
is consumed, and the dash SFX still plays. Dash direction is also locked to current velocity rather
than to the input direction, so you cannot dash toward where you are steering if you are drifting
sideways.

---

### BUG‑12 — Mothership indicator never smooths (`was_visible_on_screen` never updated) (LOW)

`scenes/ui/indicator.gd:19` declares `var was_visible_on_screen: bool = true` and it is **never
reassigned** anywhere. In `_process`:
```gdscript
var just_left_screen = was_visible_on_screen and not is_visible_on_screen   # always true offscreen
...
if just_left_screen:
    position = closest_point            # hard snap — always taken
else:
    position = position.lerp(...)       # dead branch — never reached
```
Because the flag stays `true`, `just_left_screen` is `true` on every offscreen frame, so the
indicator always hard‑snaps to the screen edge and the intended smooth lerp/rotation path is
unreachable. Cosmetic only.

---

### BUG‑13 — Black hole gulp SFX re‑plays every frame (LOW)

`scenes/black_hole/black_hole.gd:23‑27`:
```gdscript
func _process(_delta: float) -> void:
    if not check_distance:
        return
    if player and player.global_position.distance_to(global_position) < 50:
        SFXManager.play_sound(gulp_sfx)
```
`SFXManager.play_sound()` duplicates the audio player and plays it (one‑shot per call). While the
player is within 50 px, this fires every rendered frame → a growing stack of overlapping gulp
sounds. Should be one‑shot on radius‑enter or rate‑limited.

---

## Suspicious / needs a design decision (not confirmed as bugs)

- **Double `body_entered` connect on targeted bullets.** `boss_targeted_bullet.gd` re‑connects
  `body_entered` that the parent `boss_bullet.gd` already connected, so `_on_body_entered` can fire
  twice. Both paths `queue_free()`, so it is currently benign.
- **`player.gd:24` `destroy_tolerance_timer`** is initialized from the export but never used after
  `_process` decrements it — dead state, not a bug.
- **BUG‑03 carry‑over** (see above) is the main one needing a design call: is depositing meant to
  *consume* fragments, or is a refund the intended start‑of‑day allowance?
- **`sun.gd`** `queue_free()`s any non‑Player body entering the sun, including possibly the
  mothership or grav‑field bodies if an orbit drifts one in — probably safe by level layout, but
  worth a sanity check.

---

*Inventory generated from the current working tree after the cleaning pass (phases 0–5). No code
changes made; BUG‑01…13 remain in the code as documented.*