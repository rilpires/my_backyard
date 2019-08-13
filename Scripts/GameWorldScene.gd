extends WorldEnvironment

var sync_timer = Timer.new()

func _ready():
	$Character.set_script( load("res://Scenes/Controller_Character.gd") )
	$Character.fixAnimations()
	$Character.set_process_input(true)
	
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
	if( NetworkSystem.my_peer and NetworkSystem.my_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED ):
		var peer = NetworkSystem.my_peer
		var packet = [$Character.translation,$Character/Model.rotation]
		peer.transfer_mode = peer.TRANSFER_MODE_UNRELIABLE 
		#peer.put_var( packet , true )
		peer.put_packet( var2bytes(packet) )

func updateOtherPlayers():
	var other_players_parent = $OtherPlayers
	for player_state in NetworkSystem.connected_players.values():
		if( !other_players_parent.has_node( String(player_state.id) ) ):
			var new_inst = load("res://Scenes/Character.tscn").instance()
			new_inst.name = String(player_state.id)
			new_inst.set_script( load("res://Scripts/PeerPlayerController.gd") )
			new_inst.my_state = player_state
			other_players_parent.add_child( new_inst )
		var player_node = other_players_parent.get_node(String(player_state.id))


