extends "res://test_match.gd"

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
	if not root.has_node("Pong"):
		check(false, "connected match")
		quit(1)
		return
	var pong := root.get_node("Pong")
	var ball: Area2D = pong.get_node("Ball")
	deadline = Time.get_ticks_msec() + 5000
	while ball.direction.x < 0 and Time.get_ticks_msec() < deadline:
		await process_frame
	check(ball.direction.x > 0 and ball.position.x < 80, "actual left paddle collision reverses ball")
	check(ball._speed > 110 and is_equal_approx(ball.direction.length(), 1.0), "bounce accelerates normalized direction")
	check(pong.score_left == 0 and pong.score_right == 0, "bounce does not score")
	# Explicit near-win fixture, not a claimed full ten-point match or footage.
	pong.score_right = 9
	await create_timer(0.5).timeout
	if host:
		ball.position.x = -1
	deadline = Time.get_ticks_msec() + 3000
	while pong.score_right < 10 and Time.get_ticks_msec() < deadline:
		await process_frame
	await create_timer(0.3).timeout
	check(pong.score_right == 10 and pong.get_node("ScoreRight").text == "10", "terminal score replicates from boundary fixture")
	check(pong.get_node("WinnerRight").visible and not pong.get_node("WinnerLeft").visible, "correct winner shown")
	check(ball.stopped and pong.get_node("ExitGame").visible, "ball stopped and exit offered")
	if host:
		await click(pong.get_node("ExitGame"))
	deadline = Time.get_ticks_msec() + 5000
	while root.has_node("Pong") and Time.get_ticks_msec() < deadline:
		await process_frame
	check(not root.has_node("Pong") and lobby.visible and not lobby.host_button.disabled, "exit restores lobby on both peers")
	print("RESULT terminal host=", host, " failures=", failures)
	quit(1 if failures else 0)
