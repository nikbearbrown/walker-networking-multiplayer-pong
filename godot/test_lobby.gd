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
	root.size = Vector2i(640, 400)
	var scene: Control = load("res://lobby.tscn").instantiate()
	root.add_child(scene)
	var lobby: Control = scene.get_node("LobbyPanel")
	await process_frame
	await process_frame
	lobby.address.text = "not-an-ip"
	await click(lobby.join_button)
	check(lobby.status_fail.text == "IP address is invalid.", "invalid join rejected")
	check(lobby.peer == null, "invalid join creates no peer")
	await click(lobby.host_button)
	check(lobby.status_ok.text == "Waiting for player...", "loopback host waiting")
	check(lobby.host_button.disabled and lobby.join_button.disabled, "waiting disables host/join")
	check(lobby.peer != null and lobby.peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED, "host peer active")
	if lobby.peer != null:
		lobby.peer.close()
	lobby.multiplayer.multiplayer_peer = null
	print("RESULT failures=", failures, "; lobby only, no connected match tested")
	quit(1 if failures else 0)
