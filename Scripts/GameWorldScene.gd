extends WorldEnvironment

var sync_timer = Timer.new()

func _ready():
	
	add_child(sync_timer)
	sync_timer.wait_time = 0.05
	sync_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	sync_timer.one_shot = false
	sync_timer.start()
	
	sync_timer.connect("timeout",self,"_sync_tick")

func _sync_tick():
	updateOtherPlayers()
	sendMyState()

func sendMyState():
	GameContext.my_player_state.position = $Character.translation
	GameContext.my_player_state.rotation = $Character/Model.rotation
	
	if( NetworkSystem.my_peer and NetworkSystem.server_peer and
	NetworkSystem.my_peer.get_connection_status() == 2 ):
		
		var packet = GameContext.my_player_state._pack()
		if( packet != null ):
			NetworkSystem.server_peer.set_write_mode( WebSocketPeer.WRITE_MODE_BINARY )
			NetworkSystem.server_peer.put_var( packet , false )
		

func updateOtherPlayers():
	var other_players_parent = $OtherPlayers
	for player_state in NetworkSystem.connected_players.values():
		if( !other_players_parent.has_node( String(player_state.server_id) ) ):
			var new_inst = load("res://Scenes/Character.tscn").instance()
			new_inst.name = String(player_state.server_id)
			new_inst.set_script( load("res://Scripts/PeerPlayerController.gd") )
			new_inst.my_state = player_state
			other_players_parent.add_child( new_inst )
			NetworkSystem.resend_everything = true
	
	for child in other_players_parent.get_children():
		if( not NetworkSystem.connected_players.has( child.my_state.server_id ) ):
			print( child.my_state.server_id , " disconnected...")
			child.queue_free()


