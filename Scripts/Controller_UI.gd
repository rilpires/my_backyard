extends Node

var camera = null
var floor_coordinates = null

func _ready():
	camera = get_parent().find_node("Camera")

func _physics_process(delta):
	if( camera ):
		var direct_space_state = get_parent().get_world().direct_space_state
		var from = camera.project_position( get_viewport().get_mouse_position() )
		var ray_direction = camera.project_ray_normal( get_viewport().get_mouse_position() ).normalized()
		var to = from + ray_direction*100
		var result = direct_space_state.intersect_ray( from , to , [] , 1024 , true , false )
		if( not result.empty() ):
			var floor_prev = get_parent().get_node("FloorPreview")
			floor_prev.translation.x = result.position.x
			floor_prev.translation.z = result.position.z