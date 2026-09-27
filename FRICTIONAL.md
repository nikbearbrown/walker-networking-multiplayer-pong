# Verification and friction — 2026-09-24

Read all four GDScripts, project configuration and upstream README. No source
networking AGENTS.md found. Created independent copy, not a source edit. No
Godot worker was running at preflight; no visible window was opened.

Godot 4.7.2 headless import and 120-frame lobby run exited 0. Initial probe
targeted the scene root instead of LobbyPanel (where the script is attached),
raised an invalid-property error and was interrupted. Failure retained in
`lobby-20260924.log`; corrected only the diagnostic target, not the runtime scene.

`lobby-fixed-20260924.log`: five checks pass, exit 0. Test sets an invalid-address
fixture, then sends actual mouse presses/releases through root.push_input for
Join and Host. Invalid Join reports the error and creates no peer; loopback Host
reports waiting, disables both buttons and creates a connected server peer.
Peer was explicitly closed and detached before exit. No remote client connected.

NEXT: inspect game scenes and verify a real two-process localhost match with
input-driven paddle replication, ball/score behavior and orderly disconnect.
Do not advance this item on lobby-only evidence. Public networking, latency,
security, visible gameplay and both films are unverified. Shared user-closed
capture blocker remains unchanged; no review-ready or human approval claimed.

## Two-process loopback verification — 02:14 UTC heartbeat

Read the game, paddle and ball scenes. No existing Godot process was running.
`test_match.gd` launched one host with the explicit loopback flag and one client
connecting only to 127.0.0.1. Both used routed mouse events to Host/Join. Physical
W/S key events via Input.parse_input_event drove opposite paddles for 1.5s;
neither ball nor paddle state was teleported or a score handler invoked.

`match-host-20260924.log` and `match-client-20260924.log` both exit 0 with zero
failed checks (nine host, seven client). Server/client authority assignments
were correct; both peers observed Player1 at top clamp 16 and Player2 at bottom
clamp 384. Natural misses produced score 1–1 on both peers with matching labels.
Client closed its peer; host removed Pong, displayed Client disconnected and
restored enabled lobby controls. Both diagnostic processes ended, with no script
errors or leak warnings in their logs. No visible window or public listener.

Still to test: an actual paddle collision/bounce and terminal winner/exit flow.
This checks loopback state, not frame-perfect synchronization, latency resilience,
remote security or rendered footage. Both films remain pending.

## Bounce and terminal-state follow-up — 02:44 UTC heartbeat

`test_terminal.gd` uses two real loopback processes and the same routed Host/Join
and Exit Game mouse events. Without moving either paddle or ball initially,
the ball naturally collided with the left paddle. Both peers observed its
horizontal direction reverse near the paddle, speed exceed 110, normalized
direction and unchanged 0–0 score.

Terminal testing then explicitly constructed a near-win fixture: score_right=9
on each peer and, after a synchronization allowance, host ball X=-1. Normal
boundary processing/RPCs—not a direct score-handler call—produced 10 points,
the right winner, stopped ball and Exit Game button on both peers. Clicking Exit
on the host removed the match and restored each lobby. This is a fixture-based
terminal test, NOT an actual ten-point match, natural final miss or film footage.

`terminal-host-20260924.log` and `terminal-client-20260924.log` each pass seven
checks, exit 0, and contain no script errors or leak warnings. Both processes
ended. Real WAN conditions, right-paddle collision, left-winner terminal path,
security, rendered appearance and full-length match remain unverified.
Bounded local behavior verification is now sufficient to inspect the next
feasible source while this item's capture and both films remain blocked/pending.
