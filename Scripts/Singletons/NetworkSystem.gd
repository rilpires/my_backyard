extends Node

const DEFAULT_PORT = 4123

signal connection_failed
signal connection_succeeded
signal player_entered
signal player_exited
signal server_disconnected

var poll_timer
var server_peer : WebSocketPeer = null
var my_peer : NetworkedMultiplayerPeer = null
var resend_everything = false
var room_list : Dictionary = {}
var connected_players = {} # Array of PlayerState

func _ready():
	get_tree().multiplayer_poll = false
	
	var url =  "ws://localhost:"+var2str(DEFAULT_PORT)
	my_peer = WebSocketClient.new()
	print("connecting to " , url , ": " , my_peer.connect_to_url(url) )
	setupMyPeer( my_peer )

func _physics_process(delta):
	if (my_peer and my_peer.get_connection_status() != 0):
		my_peer.poll()
	else:
		return
	
	if( server_peer != null and server_peer.get_available_packet_count() > 0 ):
		var msg = server_peer.get_packet()
		if( server_peer.was_string_packet() ):
			var string_from_server = msg.get_string_from_utf8()
			
			if( string_from_server.substr(0,3) == "id:" ):
				var received_id = int(string_from_server)
				GameContext.my_player_state.server_id = received_id
				if( GameContext.my_player_state.name.length() == 0 ):
					GameContext.my_player_state.name = "Player_" + String(received_id)
				print("My server_id: " , received_id )
			
			elif( string_from_server.substr(0,3) == "dc:" ):
				connected_players.erase(int(string_from_server))
			
			if( string_from_server.substr(0,6) == "rooms:" ):
				string_from_server.erase(0,6)
				room_list = parse_json( string_from_server )
			
		else:
			msg = bytes2var(msg)
			if( typeof(msg) == TYPE_DICTIONARY ):
				var player_server_id = msg.id
				if( not connected_players.has(player_server_id) ):
					connected_players[player_server_id] = load("res://Scripts/PlayerState.gd").new(player_server_id)
				connected_players[player_server_id]._unpack(msg)

func connectTo( room_name ):
	if( server_peer and my_peer.get_connection_status() == 2 ):
		server_peer.set_write_mode( WebSocketPeer.WRITE_MODE_TEXT )
		server_peer.put_packet( room_name.to_utf8() )

func setupMyPeer(p):
	get_tree().network_peer = p
	p.connect("connection_failed",self,"_connection_failed")
	p.connect("connection_succeeded",self,"_connection_succeeded") #networked multiplayer
	p.connect("connection_established",self,"_connection_succeeded") # specific for ws
	p.connect("server_disconnected",self,"_server_disconnected")

func _connection_failed():
	print("Connection failed :(")
	emit_signal("connection_failed")
func _connection_succeeded(protocol=null):
	print("Yay!! Connection succeeded!!" )
	server_peer = my_peer.get_peer(1)
	emit_signal("connection_succeeded")
func _server_disconnected():
	print("Server disconnected :(")
	emit_signal("server_disconnected")


