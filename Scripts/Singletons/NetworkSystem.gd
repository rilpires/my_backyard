extends Node

const DEFAULT_PORT = 31417

signal connection_failed
signal connection_succeeded
signal player_entered
signal player_exited
signal server_disconnected

var poll_timer
var im_host = false
var using_websocket = false
var my_peer : NetworkedMultiplayerPeer = null
var connected_peers = []
var connected_players = {} # Array of PlayerState

func _ready():
	match (OS.get_name()):
		"Windowsss":
			my_peer = NetworkedMultiplayerENet.new()
			get_tree().multiplayer_poll = true
		_:
			using_websocket = true
			get_tree().multiplayer_poll = false

func _physics_process(delta):
	if my_peer and using_websocket and im_host and my_peer.is_listening():
		my_peer.poll()
	elif my_peer and using_websocket and not im_host and my_peer.get_connection_status() != 0:
		my_peer.poll()
	else:
		return
	
	for peer_id in connected_peers:
		var ws_peer = my_peer.get_peer(peer_id)
		if( ws_peer != null ):
			if( ws_peer.get_available_packet_count() > 0 ):
				var player_state = connected_players[peer_id]
				var msg = ws_peer.get_var()
				# print("msg size: " , var2bytes(msg).size() )
				player_state._unpack(msg)
		else:
			connected_peers.erase(peer_id)

func connectTo( ip_address , port ):
	im_host = false
	
	if( using_websocket ):
		var url =  "ws://" + "localhost:"+var2str(port)+"/"
		my_peer = WebSocketClient.new();
		print("connecting to " , url , ": " , my_peer.connect_to_url(url) )
	else:
		print("creating client: " , my_peer.create_client( ip_address , port ) )
	
	setupMyPeer( my_peer )

func createServer( port ):
	im_host = true
	
	if( using_websocket ):
		my_peer = WebSocketServer.new()
		print("listening server on port " , port , ": " , my_peer.listen( port ) )
	else:
		print("creating server: " , my_peer.create_server( port , 7 ) )
	
	setupMyPeer( my_peer )

func setupMyPeer(p):
	get_tree().network_peer = p
	p.connect("connection_failed",self,"_connection_failed")
	p.connect("connection_succeeded",self,"_connection_succeeded")
	p.connect("peer_connected",self,"_peer_connected")
	p.connect("peer_disconnected",self,"_peer_disconnected")
	p.connect("server_disconnected",self,"_server_disconnected")
	if( using_websocket ):
		if(im_host):
			p.connect("client_connected",self,"_peer_connected")
		else:
			p.connect("connection_established",self,"_connection_succeeded")

func _connection_failed():
	print("Connection failed :(")
	emit_signal("connection_failed")
func _connection_succeeded(protocol=null):
	print("Yay!! Connection succeeded!! meu id eh " , my_peer.get_unique_id() )
	if(im_host == false): _peer_connected(1,protocol) # We need to add host as peer...
	emit_signal("connection_succeeded")
func _peer_connected(id,protocol=null):
	print("someone connected, id: " , id , ", protocol: " , null , " (meu id eh )" , my_peer.get_unique_id() )
	connected_peers.push_back( id )
	connected_players[ id ] = load("res://Scripts/PlayerState.gd").new( id )
	emit_signal("player_entered", connected_players[id] )
func _peer_disconnected( id ):
	print("someone disconnected")
	connected_peers.erase( id )
	emit_signal("player_exited", connected_players[id] )
	connected_players.erase( id )
func _server_disconnected():
	print("Server disconnected :(")
	emit_signal("server_disconnected")


