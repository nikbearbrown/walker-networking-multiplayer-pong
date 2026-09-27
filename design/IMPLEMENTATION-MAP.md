# walker-networking-multiplayer-pong — Implementation map

| | |
|---|---|
| Version | 0.1.0-recovered |
| Date | 2026-09-27 |
| Author | Zelda (agent, silent) for Nik Bear Brown |
| Mode | recovered, silent (`/gdd reverse --path godot`, pass 1) |

gate — unsigned at time of writing

Every row is `[OBSERVED]` unless marked `[INFERRED]` or proposed. Line numbers were read with `cat -n` / `grep -n` on 2026-09-27. No git history was read. Engine detected: Godot, `config/features "4.7"` (`godot/project.godot:19`); logs ran v4.7.2.stable.official.ed1daf0bf (`import-20260924.log:1`); renderer `gl_compatibility` (`godot/project.godot:55-56`).

## Scenes

| Path | Root node | Children (type) | Script | Notes |
|---|---|---|---|---|
| `godot/lobby.tscn` | `Lobby` Control (line 5) | Title Label; `LobbyPanel` Panel (41) with AddressLabel, Address LineEdit (68, default `127.0.0.1` line 76), HostButton (78), JoinButton (88), StatusOk/StatusFail Labels (98, 108), PortForward Label (119, hidden), FindPublicIP LinkButton (137, hidden) | `lobby.gd` on **LobbyPanel**, not the root (line 56) | main scene (`project.godot:18`); signal connections lines 153-155 |
| `godot/pong.tscn` | `Pong` Node2D (line 8) | ColorRect bg (11), Separator Sprite2D (18), Player1 paddle instance (22, cyan, `left = true`), Player2 paddle instance (27, magenta), Ball instance (31), ScoreLeft/ScoreRight Labels (34, 43), WinnerLeft/WinnerRight Labels (52, 62, hidden), ExitGame Button (72, hidden), Camera2D (82) | `logic/pong.gd` | instantiated at runtime by `lobby.gd:30`; ExitGame connection line 85 |
| `godot/paddle.tscn` | `Paddle` Area2D (line 10) | Sprite2D (13), CollisionShape2D named `Shape3D` with CapsuleShape2D r 4.79 h 23.61 (6-8, 16), `You` Label (19) | `logic/paddle.gd` | `area_entered` → `_on_paddle_area_enter` line 28 |
| `godot/ball.tscn` | `Ball` Area2D (line 9) | Sprite2D (12), CollisionShape2D named `Shape3D` with CircleShape2D r 5.12 (6-7, 15) | `logic/ball.gd` | |

## Scripts

No script declares `class_name` (`godot/.godot/global_script_class_cache.cfg`: `list=[]`). One `@export` in the project (`paddle.gd:5`). No autoloads.

| Path | extends | Consts (tuning) | @export | signals | @rpc | Owns |
|---|---|---|---|---|---|---|
| `godot/logic/lobby.gd` | Control (1) | `DEFAULT_PORT = 8910` (6) | — | connects to `multiplayer` signals peer_connected, peer_disconnected, connected_to_server, connection_failed, server_disconnected (20-24) | — | host (88-109), join (112-124), `--walker-loopback` bind (92-93), end game (64-75), status text (78-85), public-IP link (127-128) |
| `godot/logic/pong.gd` | Node2D (1) | `SCORE_TO_WIN = 10` (5) | — | `game_finished()` (3), emitted line 53 | `update_score` any_peer, call_local (30-49) | authority assignment (16-25), score + win (30-49), exit (52-53) |
| `godot/logic/paddle.gd` | Area2D (1) | `MOTION_SPEED = 150` (3); clamp 16 / height−16 (32) | `left: bool = false` (5) | — | `set_pos_and_motion` unreliable (36-39) | input + move (12-32), "You" label (42-44), bounce trigger (47-50) |
| `godot/logic/ball.gd` | Area2D (1) | `DEFAULT_SPEED = 100.0` (3); +delta speed/frame (12); ×1.1 per bounce (52) | — | — | `bounce` (44-54), `stop` (57-59), `_reset_ball` (62-69), all any_peer, call_local | flight (11-22), goal-line checks (24-41) |

## Input actions (`godot/project.godot` `[input]`, lines 33-50)

| Action | Events | Deadzone | Read at |
|---|---|---|---|
| `move_up` | physical Up (4194320), physical W (87), joypad button 11, joypad axis 1 −1.0 (37-40) | 0.2 (36) | `paddle.gd:15` |
| `move_down` | physical Down (4194322), physical S (83), joypad button 12, joypad axis 1 +1.0 (45-48) | 0.2 (44) | `paddle.gd:15` |

`[INFERRED]` joypad buttons 11/12 are D-pad up/down (Godot 4 JoyButton enum).

## Collision layers

No `[layer_names]` section in `project.godot`; no `collision_layer`/`collision_mask` set in any `.tscn`. `[INFERRED]` Paddle and Ball Area2Ds use the default layer 1 / mask 1, so a paddle's `area_entered` fires on the ball (and would on the other paddle, which never overlaps it given x≈32 vs x≈609, `pong.tscn:24,29`).

## Autoloads

None (no `[autoload]` section in `godot/project.godot`).

## Network surface

| Item | Value | Where |
|---|---|---|
| Transport | `ENetMultiplayerPeer` (UDP) | `lobby.gd:16,89,118` |
| Port | 8910 | `lobby.gd:6`; hint text `lobby.tscn:133-135` |
| Max clients | 1 | `lobby.gd:94` |
| Bind | all interfaces by default; 127.0.0.1 with user arg `--walker-loopback` | `lobby.gd:92-93` |
| Compression | `COMPRESS_RANGE_CODER` both sides | `lobby.gd:99,120` |
| Authority | Player2 → client peer; Player1, Ball → server (default) `[INFERRED for defaults]` | `pong.gd:20-25` |
| RPC `set_pos_and_motion` | unreliable, authority only | `paddle.gd:36`; called `paddle.gd:24` |
| RPC `bounce` | any_peer, call_local | `ball.gd:44`; called `paddle.gd:50` |
| RPC `stop` | any_peer, call_local | `ball.gd:57`; called `pong.gd:49` |
| RPC `_reset_ball` | any_peer, call_local | `ball.gd:62`; called `ball.gd:32,41` |
| RPC `update_score` | any_peer, call_local | `pong.gd:30`; called `ball.gd:31,40` |
| Outbound web | `OS.shell_open("https://icanhazip.com/")` | `lobby.gd:128` |

## Assets

| Category | Count | Files | Maturity |
|---|---|---|---|
| Sprites (PNG) | 3 | `ball.png` 8×8, `paddle.png` 8×32, `separator.png` 2×400 | L1 placeholder-grade, upstream |
| Icon | 1 | `icon.webp` | upstream |
| Screenshots | 1 | `godot/screenshots/pong_multiplayer.png` 640×400 (upstream, `.gdignore` present) | upstream reference, not a Walker capture |
| Audio | 0 | — | — |
| Fonts | 0 | default theme; Title font size 32 override `lobby.tscn:36` | — |
| Import sidecars | 4 | `*.png.import`, `icon.webp.import` | — |

## Feature id → code

| Feature | Code paths |
|---|---|
| F-01 Host/join | `godot/logic/lobby.gd:88-124`; `godot/lobby.tscn:68-96,153-154` |
| F-02 Authority split | `godot/logic/pong.gd:16-25` |
| F-03 Paddle input + replication | `godot/logic/paddle.gd:12-39`; `godot/project.godot:33-50` |
| F-04 Ball sim + synced bounce | `godot/logic/ball.gd:11-54`; `godot/logic/paddle.gd:47-50`; `godot/paddle.tscn:28` |
| F-05 Split goal-line scoring + reset | `godot/logic/ball.gd:24-41,62-69`; `godot/logic/pong.gd:30-37` |
| F-06 Win, stop, exit | `godot/logic/pong.gd:39-53`; `godot/pong.tscn:52-80,85`; `godot/logic/lobby.gd:32,64-75` |
| F-07 Disconnect / failure | `godot/logic/lobby.gd:38-60,64-75` |
| F-08 `--walker-loopback` | `godot/logic/lobby.gd:92-93` |
| F-09 "You" label | `godot/paddle.tscn:19-26`; `godot/logic/paddle.gd:17-18,25-27,42-44` |
| F-10 Port-forward hint + public IP | `godot/logic/lobby.gd:108-109,127-128`; `godot/lobby.tscn:119-151,155` |

## Diagnostics and test harnesses

Supporting diagnostics, not the product. All extend `SceneTree`, exit 2 without `--walker-loopback`, and use routed mouse clicks (`root.push_input`).

| Script | Mode | Checks | Lines |
|---|---|---|---|
| `godot/test_lobby.gd` | one process | 5 | checks 35-40; flag guard 24-26 |
| `godot/test_match.gd` | two processes; `--test-host` selects host | 9 host / 7 client | checks 39-69; W/S events 46-53 |
| `godot/test_terminal.gd` | two processes; extends `test_match.gd` (line 1) | 7 each | checks 28-48; fixture score 9 at line 32, host ball x = −1 at line 35 |

No `diagnostic-*` sibling folders exist for this project. No `VERIFICATION.md`, `CAPTURE-PLAN.md` or `NETWORK-TEST-PLAN.md` in the folder; `FRICTIONAL.md` is the verification narrative.

## Logs as evidence

| Log | Shows | Result |
|---|---|---|
| `import-20260924.log` | headless import, Godot 4.7.2, 4 assets reimported | clean |
| `runtime-20260924.log` | engine banner only | `[INFERRED]` the 120-frame lobby run, reported exit 0 in `FRICTIONAL.md:7` |
| `lobby-20260924.log` | first probe: `SCRIPT ERROR ... 'address' on a base object of type 'Control'` at `test_lobby.gd:32` | harness bug (wrong node target), fixed in the test only (`FRICTIONAL.md:8-10`) |
| `lobby-fixed-20260924.log` | 5 PASS, failures=0, "lobby only, no connected match tested" | pass |
| `match-host-20260924.log` / `match-client-20260924.log` | 9 / 7 PASS; SCORES 1 1 | pass |
| `terminal-host-20260924.log` / `terminal-client-20260924.log` | 7 / 7 PASS | pass (terminal via fixture) |
