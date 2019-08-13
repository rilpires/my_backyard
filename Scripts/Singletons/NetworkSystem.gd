extends Node

const DEFAULT_PORT = 31417

signal connection_failed
signal connection_succeeded
signal player_entered
signal player_exited
signal server_disconnected

var poll_timer
var im_host = false
var my_peer : NetworkedMultiplayerPeer = null
var connected_peers = []
var connected_players = {}

func _ready():
	my_peer = NetworkedMultiplayerENet.new()
	my_peer.connect("connection_failed",self,"_connection_failed")
	my_peer.connect("connection_succeeded",self,"_connection_succeeded")
	my_peer.connect("peer_connected",self,"_peer_connected")
	my_peer.connect("peer_disconnected",self,"_peer_disconnected")
	my_peer.connect("server_disconnected",self,"_server_disconnected")
	
	poll_timer = Timer.new()
	add_child(poll_timer)
	poll_timer.wait_time = 0.1
	poll_timer.one_shot = false
	poll_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	#poll_timer.connect("timeout",self,"_poll_timer")
	poll_timer.start()

func _physics_process(delta):
	if( my_peer.get_connection_status() == 2 ):
		my_peer.poll()
		while( my_peer.get_available_packet_count() > 0 ):
			var packet_peer_id = my_peer.get_packet_peer()
			var packet_address = my_peer.get_peer_address( packet_peer_id )
			var packet_port = my_peer.get_peer_port( packet_peer_id )
			var packet_channel = my_peer.get_packet_channel()
			var msg = my_peer.get_var(true)
			print("bytesize: " , var2bytes(msg).size() )
			
			#print("message from: " , packet_address , ":" , packet_port )
			#print( msg )
			
			var player_that_sent = connected_players[packet_peer_id]
			# Reliable channel
			if( packet_channel == 1 ):
				GameContext.gui.chat_log.addPlayerMessage( player_that_sent.color , "other" , msg )
			
			# Unreliable ordered channel
			elif( packet_channel == 2 ):
				player_that_sent.position = msg[0]
				player_that_sent.rotation = msg[1]
	

func connectTo( ip_address , port ):
	var connection_status = my_peer.get_connection_status()
	if( connection_status == NetworkedMultiplayerPeer.CONNECTION_CONNECTED
	or connection_status == NetworkedMultiplayerPeer.CONNECTION_CONNECTING ):
		return
	im_host = false
	print("creating client: " , my_peer.create_client( ip_address , port ) )
	get_tree().network_peer = my_peer

func createServer( port ):
	var connection_status = my_peer.get_connection_status()
	if( connection_status == NetworkedMultiplayerPeer.CONNECTION_CONNECTED
	or connection_status == NetworkedMultiplayerPeer.CONNECTION_CONNECTING ):
		return
	im_host = true
	print("creating server: " , my_peer.create_server( port , 7 ) )
	get_tree().network_peer = my_peer

func _connection_failed():
	print("Connection failed :(")
	emit_signal("connection_failed")
func _connection_succeeded():
	print("Yay!! Connection succeeded")
	emit_signal("connection_succeeded")
func _peer_connected(id):
	print("someone connected")
	connected_peers.push_back( id )
	connected_players[ id ] = load("res://Scripts/Player.gd").new( id )
	emit_signal("player_entered", connected_players[id] )
func _peer_disconnected( id ):
	print("someone disconnected")
	connected_peers.erase( id )
	emit_signal("player_exited", connected_players[id] )
	connected_players.erase( id )
func _server_disconnected():
	print("Server disconnected :(")
	emit_signal("server_disconnected")


