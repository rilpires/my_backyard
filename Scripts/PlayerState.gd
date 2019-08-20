extends Reference

var server_id = null
var name = ""
var color = Color( 1.0 , 1.0 , 1.0 )
var position = Vector3()
var rotation = Vector3()
var txt_message = ""

var last_position_sent = position 
var last_rotation_sent = rotation
var last_txt_message_sent = txt_message
var last_name = name
var last_color = color

func _init( _server_id ):
	server_id = _server_id
	color = Color( 1.0 , 0 , 0 )
	var r = rand_seed( OS.get_time().second )[0]
	r = float(r%100)/100.0
	color = color.from_hsv( r , 1.0 , 1.0 )

func _pack():
	var pack = {}
	
	if( NetworkSystem.resend_everything or rotation != last_rotation_sent ):
		pack.rot = rotation
		last_rotation_sent = rotation
	if( NetworkSystem.resend_everything or position != last_position_sent ):
		pack.pos = position
		last_position_sent = position
	if( NetworkSystem.resend_everything or name != last_name ):
		pack.name = name
		last_name = name
	if( NetworkSystem.resend_everything or color != last_color ):
		pack.color = color
		last_color = color
	if( NetworkSystem.resend_everything or txt_message != last_txt_message_sent ):
		pack.txt = txt_message
		last_txt_message_sent = txt_message
	
	NetworkSystem.resend_everything = false
	if( pack.keys().size() == 0 ): 
		return null 
	else:
		pack.id = server_id
		return pack

func _unpack( pack ):
	if( pack.has("pos") ):
		position = pack.pos
	if( pack.has("rot") ):
		rotation = pack.rot
	if( pack.has("name") ):
		name = pack.name
	if( pack.has("color") ):
		color = pack.color
	if( pack.has("txt") ):
		GameContext.gui.chat_log.addPlayerMessage( self , pack.txt )

func getCharacterNode():
	var all_characters = GameContext.get_tree().get_nodes_in_group("Character")
	if( self == GameContext.my_player_state ):
		for character in all_characters:
			if character.is_in_group("Player"):
				return character
	else:
		for character in all_characters:
			if not character.is_in_group("Player") and character.my_state == self:
				return character
	return null
















