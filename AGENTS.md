# AGENTS.md — vox vacui (RogueSpace)

> Working notes for LLM agents (and humans) working on this codebase.
> Project folder: `RogueSpace-main` · Godot 4.5 · Forward Plus renderer.

---

## Synopsis

*Vox Vacui* is a 2D physics-driven survival game with a focus on the narrative. You play an cosmonaut adrift in the void. The only way to survive is to break down asteroid fragments and harvest their resources, this solar system is also infested with aggressive insectoid aliens.

Core loop: **drift → break asteroids → collect resources → reach the mothership → deposit → advance the day** across three increasingly hostile day-levels, all while managing fuel, breaking trajectory, and fighting off the swarm.

---

## Engine & project facts

| Fact | Value |
|---|---|
| Godot version targeted | **4.5.1** (`config/features=PackedStringArray("4.5", "Forward Plus")`, `config_version=5`) |
| Renderer | Forward Plus (2D game, but the GPU pipeline is used for shader effects) |
| Project name | `vox vacui` |
| Main scene | `res://scenes/start_limbo.tscn` (referenced by **UID** `uid://m2oqym1qilyn`, not by path!) |
| Icon | `res://VoxVacui_Icon_LowRes.png` (referenced by UID `uid://dernurpysipe2` in `project.godot`) |
| Language | GDScript (static typing wherever practical) |
| Tests | gdUnit4 (`res://addons/gdUnit4/`) — see [Testing](#testing) |

---

## Repository layout

```
res://
├── autoloads/          # autoload singletons: globals, event_*_bus, stats_manager, power_ups,
│                        #   sfx_manager, diary_database, hands_event_bus, controller_vibration
│                        #   + level_transition/input_guide/custom_tooltip/music_manager scenes
├── scenes/              # all game folders are snake_case (Godot style guide)
│   ├── levels/          # menus/ (menu, game_over, menu_buttons_control),
│   │                    #   space_levels/ (Level_Day1/2/3, input_guide_admin, space_winds_sfx, DAY3_camera_2d),
│   │                    #   spaceship_interior/ (spaceship_interior + resources_counting + spaceship_cable),
│   │                    #   tutorial/ (Tutorial, tutorial.gd, tutorial_area*.gd)
│   ├── player/          # player.gd (BodySetup), player.tscn, prtc_player_death.tscn
│   ├── asteroids/       # asteroid_body/ (asteroid_small/medium/big, asteroid.gd),
│   │                    #   asteroid_fragment/ (asteroid_fragments.tscn, asteroid_fragments.gd, fragments_sprite.gd)
│   ├── enemies/         # enemy_basic, enemy_vermin, enemy_larvae, boss, matriarch_hook.gd
│   ├── bullets/         # player_bullet.gd (shared by basic_bullet.tscn + super_bullet.tscn),
│   │                    #   boss_bullet, boss_targeted_bullet
│   ├── modulars/        # gameplay modules (composition components), map/tile generation
│   ├── space_bodies/    # body_setup.gd base, planets, sun, orbit, moons/, vulnerability_area
│   ├── black_hole/      # black_hole + supermassive_black_holes/ (renamed from BackHoles — see gotcha below)
│   ├── spaceship/       # mothership + mothership_control + mothership_enter_area;
│   │                    #   interior: diary, papers, deimos_hands, Monitor, ui/
│   ├── ui/              # in-space HUD + shared UI scripts (ui.tscn, warnings, velocity, tutorial,
│   │                    #   day, resources, rich_text_label*, button.gd, main_light.gd, game_over_control.gd)
│   ├── cutscenes/       # cutscene_context/final/final2/out_spaceship/credits
│   └── start_limbo.tscn # boot/loading scene (the MAIN scene — flagged "unused" by path-grep only!)
├── sound_effects/       # WAV/MP3 SFX (bus: "Sound Effects") — subfolders: space_bodies/, cutscenes/,
│                        #   player/, ui/, ambience/, asteroids/, collecting/, enemies/, shoot/, spaceship/
├── music/               # MP3 tracks (bus: "Music") — incl. cutscene_music/
├── sprites/             # all sprite assets (merged from Sprites_main/ → Sprites/ → sprites/)
├── shaders/             # .gdshader files (+ shaders/BlackHoleShader.gdshader)
├── fonts/               # .ttf fonts
├── tests/               # gdUnit4 suites (see Testing)
├── STYLE.md             # project code style + LLM modification rules (read before editing code)
├── TESTS.md             # gdUnit4 how-to + quirks (read before writing/running tests)
├── UNUSED_CODE.md       # audit of dead code/oddities
├── UNUSED_RESOURCES.md  # audit of dead asset resources
├── FILESYSTEM_MISTAKES.md  # filesystem org audit (misplaced/disorganized/naming — prior fixes)
└── AGENTS.md            # this file
```

> **Note on prior reorganizations:** the asset folders `Sprites/` + `Sprites(main)/` were merged into a single `Sprites_main/` (later renamed `Sprites/`, then `sprites/`); `asteroid.gd`/asteroid scenes moved to `scenes/asteroids/asteroid_body/` and fragments to `scenes/asteroids/asteroid_fragment/` (`asteroid_pieces` → `asteroid_fragments`); black-hole files moved to `scenes/black_hole/` (+ `supermassive_black_holes/`, `superm_black_hole.gd` → `supermassive_black_hole.gd`); `basic_bullet.gd` moved to `scenes/bullets/player_bullet.gd`; mothership moved to `scenes/spaceship/`; particle scenes moved to `scenes/player/` (`prtc_player_death.tscn`); all folders now snake_case per Godot style guide. The tree above is the current on-disk layout.

---

## Documentation map — what to read, and when

This project's notes are split across several files so each stays focused. **Read this file first** (it is the overview). Then, depending on the task, consult the following:

| When you… | Read | Why |
|---|---|---|
| Are about to **write or edit any code** (script, scene, resource) | **`STYLE.md`** | Authoritative style guide **plus two mandatory LLM rules**: the *Variable Re-assertion Rule* (re-assert an `@export`/constant's original value after reassigning it) and the *Preservation of Functionality Rule* (keep behavior identical — only ordering/formatting/cleaning changes unless explicitly asked). **Both are mandatory** for any LLM editing code in this repo. |
| Are about to **write, run, or debug tests** | **`TESTS.md`** | gdUnit4 how-to + the hard-won quirks (suite halts on first failure, lambda-by-value capture, two `process_frame` awaits, dead-end MCP `test_run` tool, etc.). Read it *before* touching `tests/` or running the suite. |
| Need to know **which code/scenes are dead or odd** | **`UNUSED_CODE.md`** | Audit of unused/dead scripts, unused scenes, and oddities (malformed const, trigger-not-flag setters, case-sensitivity traps). Don't re-create or re-import anything marked *resolved*. |
| Need to know **which assets (images/audio/video/shaders) are dead** | **`UNUSED_RESOURCES.md`** | Audit of unused resources and which are safe to delete. Don't re-import or re-create anything marked resolved. |
| Are about to **move/rename files or re-point references** | **`FILESYSTEM_MISTAKES.md`** | Audit of misplaced/disorganized/non-descriptive filesystem items and the reorganizations already applied. See the *Note on prior reorganization* in the layout above for the current state. |

**Fast rules of thumb:**
- Editing **code** → read `STYLE.md` first.
- Touching **tests** → read `TESTS.md` first.
- After **any** change → run the suite (see [Testing](#testing)); re-run the rescan command if you moved/renamed scripts (`/usr/local/bin/godot --headless --editor --quit --path .`) so the class cache rebuilds.
- Before **deleting** something flagged dead in the UNUSED docs, re-verify references (UID-referenced files like the main scene and the icon are invisible to path-greps).

---

## Architecture

### Autoloads (singletons)

Registered in `project.godot` `[autoload]` (order matters — later autoloads may use earlier ones):

| Name | Source | Purpose |
|---|---|---|
| `Globals` | `autoloads/globals.gd` | Global flags (`can_teleport`, `is_cutscene`, `changing_scene`, `fake_mouse_input`), `next_scene_path`, `last_level_path`, `has_energy_in_spaceship` (+ `fragments_value_to_sum`), `add_frag_sum()`, `reload_current_scene()`, `update_resources_goal()`, `reset_game_state()` |
| `EventBus` | `autoloads/event_bus.gd` | Global gameplay signals (see [Event buses](#event-buses)) |
| `SFXManager` | `autoloads/sfx_manager.gd` | One-shot SFX: `play_sound(audio_player)` duplicates the player into the current scene, plays, `queue_free`s on `finished` |
| `LevelTransition` | `autoloads/level_transition.tscn/.gd` | `change_scene_to(scene_path, fade_in, fade_out)` → deferred `change_scene_to_file` |
| `PowerUps` | `autoloads/power_ups.gd` | Power-up levels (`add_current_level`/`get_current_level`/`apply_power_up`/`reset_game_state`) |
| `ControllerVibration` | `autoloads/controller_vibration.gd` | Gamepad rumble (`vibrate_controller(strength_index, duration, controller_index)`) |
| `SpaceshipEventBus` | `autoloads/spaceship_event_bus.gd` | Mothership-UI signals (focus, resource counting) |
| `PopUpSystem` | `scenes/spaceship/ui/pop_up_control.tscn` | Interaction pop-ups |
| `StatsManager` | `autoloads/stats_manager.gd` | **Central player/game state** (see below) |
| `CustomTooltip` | `autoloads/custom_tooltip.tscn` | Tooltip overlay |
| `InputGuide` | `autoloads/input_guide.tscn` (embeds `autoloads/input_guide_unit.tscn`) | Key hints; levels use `input_guide_admin.gd` variants |
| `DiaryDatabase` | `autoloads/diary_database.gd` | Diary page content per day (`get_day(day) -> Dictionary`) |
| `HandsEventBus` | `autoloads/hands_event_bus.gd` | Deimos-hands interaction signals |
| `MusicManager` | `autoloads/music_manager.tscn/.gd` | Dual AudioStreamPlayer crossfade, `music_map` to `music/*.mp3` |
| `_mcp_game_helper` | `addons/godot_ai/runtime/game_helper.gd` | godot_ai MCP runtime bridge (addon; don't touch) |

### StatsManager — the state hub

Holds nearly all persistent/player state: `day`, `resources_needed`, `current_resources` (setter clamps to `>= 0`), `player_has_cadaver`, `PowerUpsLevels` dict, `player_current_bullet` (a `res://` scene path!), `player_have_perfurator`, and player stats. `reset_game_state()` restores every variable to its `INIT_*` constant. Many gameplay modules **read `StatsManager` dynamically at runtime** (e.g. `bullet_shooter.gd` loads `StatsManager.player_current_bullet` as a scene). Changing a default here reverberates across the game — always check callers.

### Composition over inheritance — the "modular" pattern

The defining architectural pattern: **gameplay behaviors are child-node *components*** composed in `.tscn` files, then injected by `@export` reference into a parent (typically the `owner_body` / a `target`). This is **not** inheritance — modules are separate nodes.

Key modules under `scenes/modulars/`:

| Script | Type | Behavior |
|---|---|---|
| `gravity_module.gd` | Node | Constant gravity pull toward a `target` (exports for strength/direction) |
| `hurt_module.gd` | Node2D | Owner-body hurt/damage handling (`owner_body: RigidBody2D`) |
| `hurt_box.gd` | Area2D | `HurtBox`; emits `damage_taken(amount, causer)`; `bullet_sensible` |
| `resource_collector.gd` | Area2D | `ResourceCollector`; harvests resources for `owner_body` |
| `bullet_shooter.gd` | Node2D | `BulletShooter`; fires `StatsManager.player_current_bullet` with `base_cooldown` |
| `clickable_highlight.gd` | Node2D | Hover/click interactivity (`was_clicked`, `is_on_hover`, `clicked_outside`) |
| `smooth_shake_module.gd` | Node | `SmoothShake`; per-target eased camera shake |
| `camera_vibration.gd` | Node2D | Camera shake keyed to vibration `strength_index` (0–3) |
| `black_hole_gravitational_field.gd` | GravitationalField | Black-hole gravity-field specialization |
| `map_generator.gd` | Node2D | `MapGenerator`; builds asteroid field from a noise texture into a `TileMapLayer` |
| `map_control.gd` | Node2D | `MapControl`; keeps the player inside a safe-area radius |
| `tile_map_generator.gd` | TileMapLayer | Places small/medium/large asteroid + resource scenes onto a tilemap |
| `asteroid.gd` | BodySetup | **Current** asteroid logic + `calculate_damage_and_pieces`; attached to all 3 asteroid scenes |

### BodySetup — shared body base

`res://scenes/space_bodies/body_setup.gd` (`extends RigidBody2D`, `class_name BodySetup`) is the base for all space bodies. Exported: `collision: CollisionShape2D`, `sprite: Node2D`, `gravitational_field`, `gravitational_field_resources`, `body_randomizer`.

**Extends BodySetup:** `scenes/asteroids/asteroid_fragment/asteroid_fragments.gd`, `scenes/black_hole/black_hole.gd`, `scenes/black_hole/supermassive_black_holes/supermassive_black_hole.gd`, `scenes/asteroids/asteroid_body/asteroid.gd`, `scenes/player/player.gd`, `scenes/space_bodies/boss_planet_day_3.gd`, `scenes/space_bodies/planet.gd`.

### Event buses

- **`EventBus`** (global): `player_out_of_bounds`, `player_almost_out_of_bounds`, `player_back_in_bounds`, `fuel_used`, `almost_out_of_fuel`, `out_of_fuel`, `damage_taken(damaged, amount)`, `cutscene_on/off`, `space_resource_collected`, `mothership_entrance_entered/exited`, `player_wants_to_enter_mothership`, `not_enough_resources`, `resources_used`, `level_pass`, `player_death(explode)`, `enemy_on_screen/off_screen`, `vibrate(strength_index)`, `boss_in_capture_area`, `start_planet_break`.
- **`SpaceshipEventBus`**: `focus_on`, `focus_off`, `resource_count_finished`, `resource_count_started(duration)`, `focus_changed`, `resources_spent`, `player_going_out`.
- **`HandsEventBus`**: `machine_interaction`, `monitor(state)`, `book(state)`, `page_prev`, `page_next`, `door_interaction`.

### Level progression

`StatsManager.day` starts at `0`. Resource goal per day (`Globals.update_resources_goal()`): day 0 → 50, day 1 → 100, day 2 → 200, day 3 → 0. Flow: gather resources in `Level_DayN` → enter the mothership → `resources_counting.tscn` counts the deposit (`resource_count_started/finished`, `resources_spent`) → advance day → next `Level_DayN` scene, swapped via `LevelTransition`. The exact `day += 1` wiring is not a single obvious call — trace `EventBus.resources_used` / `level_pass` before touching progression.

### Audio

Two buses (from `default_bus_layout.tres`): **"Sound Effects"** (`SFXManager` one-shots) and **"Music"** (`MusicManager` crossfade player). The `Master` bus is the default. Bus names matter in tests: black-hole gulp asserts bus `"Sound Effects"`.

### Input map (custom actions, no `ui_*`)

`move_up/down/left/right` (WASD + joy axes), `break_stop` (Alt + axis 4), `impulse_burst` (Shift + axis 5 + button 9), `restart` (R, Space), `confirm` (Space, button 0), `teleport` (T, button 3), `pause` (Escape, button 6), `menu` (M, Space), `destroy` (Space), `left_click`/`return` (mouse 1, X), `scroll_up/down`, `middle_mouse`, `test_i/j/k/l/n` (debug), `r_stk_up/down/left/right` (joypad right stick).

> **Input preference (MCP automation):** prefer **keyboard inputs** (e.g. `input_key` / `input_action` / `input_sequence`) over mouse inputs when driving the game — navigating menus *and* gameplay alike. Keyboard/action-based input is focus-independent, works on a backgrounded window, and does not depend on cursor/button geometry (which is easy to get wrong via `input_mouse`, since events may land at a stale cursor position). Fall back to mouse only when the target has no keyboard binding.

---

## Code style & LLM modification rules (IMPORTANT)

`STYLE.md` holds the authoritative style guide. Two rules there are **mandatory for any LLM editing code**:

1. **Variable Re-assertion Rule** — if a variable (especially an `@export`) is reassigned or rewritten, you **must re-assert its original value afterward** (store-original → modify → restore). Never leave a modified `@export`/constant state behind.
2. **Preservation of Functionality Rule** — code must keep functioning *exactly* as before. Only ordering, formatting, and cleaning changes are allowed; **no logic/behavior/architecture changes** unless explicitly requested.

General: UTF-8, tabs for indentation, `snake_case` for vars/functions, `PascalCase` for classes/nodes, `CONSTANT_CASE` for constants, code-order section (tool, signals, enums, consts, exports, vars, onready, methods), static typing.

---

## Testing

gdUnit4, suites live under `res://tests/` (`project.godot` `[gdunit4] settings/test/test_lookup_folder="Tests"`).

**Run the whole suite:**
```bash
cd "/mnt/c/Users/thiag/Desktop/NinaPUC/GOTY/RogueSpace-main(2)/RogueSpace-main" && \
export GODOT_BIN=/usr/local/bin/godot && \
timeout 200 ./addons/gdUnit4/runtest.sh -a res://tests --ignoreHeadlessMode
```

Currently **~210 tests across 22 suites**: `tests/autoloads/unit/` (stats_manager, power_ups, globals, diary_database, event_buses, sfx_controller) and `tests/unit/` (player, enemies, boss, bullets, asteroids, black_hole, map_generator, resource_collector, hurt/gravity modules) + `tests/menu/unit/`.

See `TESTS.md` for full details, including the gdUnit4 quirks below.

### gdUnit4 quirks (learned the hard way)

- **A failed test HALTS the whole suite file** — later tests in the same file never run. Fix the first failure before re-running.
- The godot_ai MCP `test_run` tool is a **dead end** for gdUnit4 (it hardcodes `res://tests/` + `McpTestSuite`). Use the CLI command above.
- `--ignoreHeadlessMode` is **required** (headless is otherwise blocked, exit 103).
- Lambda captures are **by value** in GDScript — capture through an array: `var flag := [false]` + `func(): flag[0] = true`, then assert `flag[0]`.
- Instantiate scenes with `load(path).instantiate()`, `add_child`, then **two** `await get_tree().process_frame` before asserting `_ready()` state.
- Type script instances as untyped `var` (typing as `Node` blocks dynamic member access).
- Must **disconnect real scene signal handlers** (e.g. bullet `body_entered` → `_on_body_entered`) before emitting signals in tests, or the engine logs `Cannot convert argument 1`.
- Express wastage: ignore `RID`/texture leak warnings at exit — they appear after `Exit code: 0` and are harmless.
- Assert API: `assert_that(x).is_equal/.is_true/.is_false/.is_null/.contains/.is_empty/.is_not_empty/.is_greater_equal/.is_less_equal`. (`is_less_or_equal` does NOT exist.)

---

## Quirks, gotchas & dead code

See `UNUSED_CODE.md` (code) and `UNUSED_RESOURCES.md` (assets) for the full audited inventory. Highlights:

- **BackHoles → black_hole (RESOLVED):** the on-disk folder is now **`scenes/black_hole/`** and every reference (level scenes `Level_Day1/2/3.tscn`, `Tutorial.tscn`, and `tests/unit/black_hole_test.gd`) consistently uses `res://scenes/black_hole/…`. Do **not** rename again.
- **`res://scenes/start_limbo.tscn` is the MAIN scene** but is flagged "unused" in path-based audits because `project.godot` references it **by UID only**, not by path. Same trap as the icon. Any path-grep-based "unused" audit must also check UID references.
- **Stale UIDs / folder renames:** renaming a folder in a scene (e.g. via editor or `git mv`) does **not** rewrite `res://` paths inside `.tscn`/`.gd` files; re-point ext_resource `path=` lines manually (or merge the upstream rename).
- `stats_manager.gd:55` `const FUEL_IMPULSE_USE_STEP: float = 0.5` — was a **malformed typed const** (`const FUEL_IMPULSE_USE_STEP: = 0.5`, missing type); fixed to `: float` during the cleaning pass (value unchanged). Tests pin the literal `0.5`. Used at `scenes/player/player.gd:201`.
- `globals.gd` `has_energy_in_spaceship` setter: setting it `true` stores `fragments_value_to_sum = StatsManager.resources_needed` and immediately self-resets to `false`; the only readable way it stays `true` is never — it's a trigger, not a flag. Tests encode this behavior.
- **`Globals.is_showing_confirmation` is synced by hand, not a pure flag:** the only writer is `scenes/spaceship/mothership_enter_area.gd:28`, which copies the entrance's local `is_showing_confirmation` every `_process`. Because entering the mothership **pauses the tree** (via `LevelTransition.change_scene_to` → `get_tree().paused = true`) before the node is freed, the global could stay `true` and permanently block pause — `scenes/ui/pause_overlay.gd:17` early-returns while `Globals.is_showing_confirmation` or `Globals.is_cutscene` is set. The fix clears the global explicitly in `_on_yes_pressed()` (alongside the local). Keep the explicit clear if you touch entry logic.
- `stats_manager.gd` `player_have_perfurator` defaults `true` (the only writer is `power_ups.gd:74`, guard at `vulnerability_area.gd:20`).
- `res://scenes/bullets/player_bullet.gd` is the shared player-bullet script, attached by both `basic_bullet.tscn` and `super_bullet.tscn` (was `res://basic_bullet.gd` at the project root, moved during reorganization).
- **Case-sensitivity trap (RESOLVED):** the folder is now **`scenes/modulars/`** (lowercase) so the old `res://Scenes/modulars/` case-mismatch in the asteroid scenes no longer breaks on case-sensitive filesystems.
- `ENEMY`/asteroid `-old` variants, `paths_hub.gd` (empty stub autoload, **already removed** from `project.godot`), unused planet/moon scenes, and a large inventory of unused images/videos/audio/shaders are documented in the two UNUSED docs (assets already deleted are marked resolved; **do not re-import or re-create them**).
- `icon.svg` (default Godot icon) and `default_bus_layout.tres` were audited as unused but **kept by user decision** (verify before touching).

---

## Editing conventions for this repo

- Prefer composition (modulars child nodes) when adding behaviors.
- Route runtime state through `StatsManager`/`Globals` autoloads rather than new globals.
- Emit cross-system events via the three event buses; don't wire scenes to each other directly.
- Keep `@export` names descriptive (`owner_body`, `target`, `gravitational_field`…) and match existing module conventions.
- Run the gdUnit4 suite after touching any gameplay script — physics-heavy handlers often can't be unit-tested, so keep pure logic (defaults, calculations, state transitions) testable.
