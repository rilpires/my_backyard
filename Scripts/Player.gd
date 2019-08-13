extends Reference

var id = null
var name = ""
var color = Color( 1.0 , 1.0 , 1.0 )
var position = Vector3()
var rotation = Vector3()

func _init( _id ):
	id = _id
	color = Color( 1.0 , 0 , 0 )
	var r = rand_seed( OS.get_time().second )[0]
	r = float(r%100)/100.0
	color = color.from_hsv( r , 1.0 , 1.0 )
	