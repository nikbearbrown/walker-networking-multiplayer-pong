extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
	print("PASS " if ok else "FAIL ", label)

func click(button: Button) -> void:
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = button.get_global_rect().get_center()
		event.global_position = event.position
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		root.push_input(event, true)
		await process_frame

func run() -> void:
	if not "--walker-loopback" in OS.get_cmdline_user_args():
		quit(2)
		return
	var host := "--test-host" in OS.get_cmdline_user_args()
	root.size = Vector2i(640, 400)
	var scene: Control = load("res://lobby.tscn").instantiate()
	root.add_child(scene)
	var lobby: Control = scene.get_node("LobbyPanel")
	await process_frame
	await process_frame
	lobby.address.text = "127.0.0.1"
	await click(lobby.host_button if host else lobby.join_button)
	var deadline := Time.get_ticks_msec() + 10000
	while not root.has_node("Pong") and Time.get_ticks_msec() < deadline:
		await process_frame
	check(root.has_node("Pong"), "connected match exists")
	if not root.has_node("Pong"):
		quit(1)
		return
	var pong := root.get_node("Pong")
	check(pong.get_node("Player1").get_multiplayer_authority() == 1, "player1 server authority")
	check(pong.get_node("Player2").get_multiplayer_authority() != 1, "player2 client authority")
	var event := InputEventKey.new()
	event.physical_keycode = KEY_W if host else KEY_S
	event.pressed = true
	Input.parse_input_event(event)
	await create_timer(1.5).timeout
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await create_timer(0.5).timeout
	check(absf(pong.get_node("Player1").position.y - 16.0) < 1, "host input and replication reach top clamp")
	check(absf(pong.get_node("Player2").position.y - 384.0) < 1, "client input and replication reach bottom clamp")
	await create_timer(7.0).timeout
	print("SCORES ", pong.score_left, " ", pong.score_right)
	check(pong.score_left >= 1 and pong.score_right >= 1, "natural misses score on both peers")
	check(pong.get_node("ScoreLeft").text == str(pong.score_left) and pong.get_node("ScoreRight").text == str(pong.score_right), "score labels follow state")
	if not host:
		lobby.peer.close()
		lobby.multiplayer.multiplayer_peer = null
	else:
		deadline = Time.get_ticks_msec() + 5000
		while root.has_node("Pong") and Time.get_ticks_msec() < deadline:
			await process_frame
		check(not root.has_node("Pong"), "disconnect removes match")
		check(lobby.visible and not lobby.host_button.disabled and lobby.status_fail.text == "Client disconnected.", "disconnect restores lobby")
	print("RESULT host=", host, " failures=", failures)
	quit(1 if failures else 0)
