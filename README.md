# Walker — Multiplayer Pong

Walker's independent local copy of the official Godot networking demo `networking/multiplayer_pong`: two peers play Pong over ENet, one hosting and one joining. It is a tech demo, not a designed game; it exists in Walker as an adaptation of the upstream Godot demo, and it shows how multiplayer authority is split so that each peer owns its own paddle and its own goal line. Headless loopback tests on 2026-09-24 (Godot 4.7.2) passed for the lobby, a connected two-process match (authority, paddle input and replication, natural scoring, host-side disconnect), a left-paddle bounce, and a fixture-based win and exit. Public networking, latency, security, the right-paddle bounce, the left-winner path, a full-length match and rendered footage are not verified. Both native-4K Liam films remain pending under the shared capture blocker.

## How to run

- Open `godot/project.godot` in Godot 4.7 (the project declares feature `4.7`; the verification logs ran Godot v4.7.2.stable). Renderer: Compatibility. Main scene: `lobby.tscn`.
- Run two instances. In one, press **Host** (server on UDP port 8910, one client). In the other, type the host's IP address (default `127.0.0.1`) and press **Join**. The match starts as soon as the client connects.
- Controls: `move_up` = W, Up arrow, D-pad up or left stick up; `move_down` = S, Down arrow, D-pad down or left stick down. Each player moves only their own paddle (host: left, cyan; client: right, magenta).
- First to 10 points wins; **Exit Game** returns both peers to the lobby.
- Walker flag: pass `--walker-loopback` as a user argument (after `--` on the Godot command line) to bind hosting to 127.0.0.1 so no LAN listener is exposed. Without it, hosting uses the upstream default.
- Diagnostics: `godot/test_lobby.gd`, `godot/test_match.gd` and `godot/test_terminal.gd` are `SceneTree` scripts that exit with code 2 unless `--walker-loopback` is given; the match and terminal tests run as two processes, with `--test-host` on the host process. Their outputs are the `*-20260924.log` files in this folder.

## Design

- [GDD.md](GDD.md) (identical copy of [design/GDD.md](design/GDD.md))
- [design/DECK.html](design/DECK.html) — review slides
- [design/IMPLEMENTATION-MAP.md](design/IMPLEMENTATION-MAP.md) — scenes, scripts, inputs, RPCs, feature → code
- [design/decisions.md](design/decisions.md) — open questions

The GDD is a recovered, unapproved description of what the code does, written in a silent Zelda pass on 2026-09-27. No design gate is signed. It lists 12 open questions, starting with why Walker keeps this demo and what evidence closes the item.

## Source & license

Independent local copy of Godot `networking/multiplayer_pong`, source commit `a3b5c113112f77291d5f3d1360f33a882fdc52f7`. Original source is untouched; the Godot contributor MIT notice is retained in [LICENSE.md](LICENSE.md). Original assets, UIDs/import settings and README remain under `godot/`.

Local adaptations: Walker title and the opt-in `--walker-loopback` user argument that binds hosting to 127.0.0.1 for local verification. Normal defaults otherwise remain upstream. No public IP lookup or port forwarding was performed.

## Status

- Verified on loopback only (see [FRICTIONAL.md](FRICTIONAL.md) and the `*-20260924.log` files): headless import and a 120-frame lobby run exit 0; lobby checks pass (invalid join rejected, loopback host waiting); a two-process match passes with correct server/client authority, W/S input replicated to both clamps, natural misses scoring 1–1 on both peers, and the host restoring its lobby with "Client disconnected."; a left-paddle bounce reverses and speeds up the ball without scoring; a near-win fixture (score set to 9) reaches 10 through normal boundary processing, shows the right winner, stops the ball and offers Exit, which restores both lobbies. This is a fixture-based terminal test, not an actual ten-point match.
- Not verified: real WAN conditions, latency resilience, frame-perfect synchronization, remote security, right-paddle collision, left-winner terminal path, full-length match, rendered appearance.
- Both native-4K Liam films remain pending under the shared capture blocker. No review-ready or human approval is claimed.

Repository: https://github.com/nikbearbrown/walker-networking-multiplayer-pong
