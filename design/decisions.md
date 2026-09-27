# Open questions log — walker-networking-multiplayer-pong

gate — unsigned at time of writing

Recovered 2026-09-27 by Zelda (agent, silent) for Nik Bear Brown. Every `[MISSING]` tag in `GDD.md` is one row here: 12 open questions. Nothing is decided.

Format per entry: THE QUESTION / THE STAKES / DECISION DEADLINE / OPTIONS / OWNER / STATUS.
Status is Open, In Discussion, or Decided. Decided items move into their section before the next session.

| # | Question | Stakes | Deadline | Options | Owner | Status |
|---|---|---|---|---|---|---|
| Q-01 | Why does Walker keep this demo: what should it teach or prove? (GDD §1) | Ghost Center: without it no test, film, or edit can be judged as done or off-target | before any further test or film work | (a) teaching sample for networked authority; (b) regression fixture for Godot networking; (c) starting point for a Walker game; (d) archive only | Nik Bear Brown | Open |
| Q-02 | Who is the "player": someone playing, or a developer reading the code? (GDD §1, §4) | Decides whether PX goals are feelings or code-legibility goals, and what a playtest even is | with Q-01 | players / developers / students / both | Nik Bear Brown | Open |
| Q-03 | What are the design pillars, if any? (GDD §2) | Without them there is no rule to reject a change (e.g. adding lag compensation vs keeping "smooth local motion") | after Q-01 | adopt the three inferred candidates / write new / none (pure upstream copy) | Nik Bear Brown | Open |
| Q-04 | What Player Experience Goals apply? (GDD §4) | PX candidates are network properties; nothing can be playtested for experience | after Q-02 | adopt PX-01..04 candidates / rewrite / none | Nik Bear Brown | Open |
| Q-05 | Faithful upstream copy, or does Walker extend it (more players, WAN, audio, rematch, progression)? (GDD §3, §7, §12) | Every out-of-scope item in §12 is one decision away from scope creep | before any gameplay code change | (a) freeze as upstream + loopback flag; (b) extend with a named list | Nik Bear Brown | Open |
| Q-06 | CORE is 5/10 = 50% (44% even with F-04/F-05 merged). Cut or extend? (GDD §11) | Core-percentage rule breach; low practical risk since all features exist | before any new feature is added | (1) accept a reduced demo scope; (2) keep the CORE list and extend the timeline | Nik Bear Brown | Open |
| Q-07 | Trust model: may either peer call `update_score`, `bounce`, `stop`, `_reset_ball`? (GDD §6 S-02, §14 R-01) | Any client can award points or stop the ball; security is unverified | before any non-loopback or public use | (a) trusted-LAN demo, document the risk; (b) add sender checks; (c) server-authoritative ball | Nik Bear Brown | Open |
| Q-08 | What ball-position divergence between peers is acceptable? (GDD §6 S-03) | No pass/fail criterion exists for sync, so T-13 cannot be written | before T-13 | a pixel/time bound / "scores must agree" only / not a goal | Nik Bear Brown | Open |
| Q-09 | Are the upstream tuning values Walker's design? (speed 100, +1/s, ×1.1 per bounce, paddle 150, clamp 16, win 10) (GDD §5) | Recorded as observed, not approved; any retune has no baseline | before any retune | keep as upstream / retune with stated goal | Nik Bear Brown | Open |
| Q-10 | What evidence closes this Walker item: films, a human session, WAN test, all unverified branches? (GDD §16, §14 R-05) | Item can stall indefinitely on the capture blocker or close on loopback evidence alone | now | (a) loopback logs suffice; (b) + T-07..T-12; (c) + films; (d) + human session | Nik Bear Brown | Open |
| Q-11 | Keep the port-forward hint and the icanhazip.com link in the Walker copy? (GDD §5 M-08) | Outbound third-party link and a UI invitation to expose a UDP port | before any public build or film | keep / hide behind `--walker-loopback` / remove | Nik Bear Brown | Open |
| Q-12 | Track upstream (`a3b5c113…`) or freeze? (GDD §13) | Drift from upstream fixes vs stable verified baseline | before next upstream demo sync | freeze / periodic re-copy / track with diff | Nik Bear Brown | Open |
