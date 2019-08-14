extends Reference

var id = null
var name = ""
var color = Color( 1.0 , 1.0 , 1.0 )
var position = Vector3()
var rotation = Vector3()

var last_position_sent = position 
var last_rotation_sent = rotation

func _init( _id ):
	id = _id
	color = Color( 1.0 , 0 , 0 )
	var r = rand_seed( OS.get_time().second )[0]
	r = float(r%100)/100.0
	color = color.from_hsv( r , 1.0 , 1.0 )

func _pack():
	var pack = {}
	
	if( rotation != last_rotation_sent ):
		pack.rot = rotation
		last_rotation_sent = rotation
	if( position != last_position_sent ):
		pack.pos = position
		last_position_sent = position
	
	if( pack.keys().size() == 0 ): 
		return null 
	else: 
		return pack

func _unpack( pack ):
	if( pack.has("pos") ):
		position = pack.pos
	if( pack.has("rot") ):
		rotation = pack.rot

