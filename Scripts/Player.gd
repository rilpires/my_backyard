extends Reference

var player_name = ""
var color = Color( 1.0 , 1.0 , 1.0 )
var position = Vector3()

func _init():
	color = Color( randf() , randf() , randf() )
