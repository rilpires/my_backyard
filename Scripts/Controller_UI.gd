extends Node

var camera = null
# warning-ignore:unused_class_variable
var floor_coordinates = null

func _ready():
	camera = get_parent().find_node("Camera")

func _input(event):
	if( camera and GameContext.gui and
	(event is InputEventMouseMotion or
	event is InputEventKey) ):
		var mouse_position = get_viewport().get_local_mouse_position()
		var direct_space_state = camera.get_world().direct_space_state
		var from = camera.project_position( mouse_position, 1 )
		var ray_direction = camera.project_ray_normal( mouse_position ).normalized()
		var to = from + ray_direction*100
		var result = direct_space_state.intersect_ray( from , to , [] , 1 + 1024 + 2048 , true , false )
		var floor_prev = get_parent().get_node("FloorPreview")
		floor_prev.hide()
		if( result.empty() ):
			GameContext.gui.setHovered( null )
		else:
			
			if( result.collider.is_in_group("Floor") ):
				GameContext.gui.setHovered( null )
				var cell_size = GameContext.current_game_world.MAP_CELL_SIZE
				var cell_x = floor(result.position.x / cell_size) * cell_size
				var cell_z = floor(result.position.z / cell_size) * cell_size
				floor_prev.show()
				floor_prev.translation.x = cell_x + cell_size*0.5
				floor_prev.translation.z = cell_z + cell_size*0.5
			
			if( result.collider.is_in_group("Character") ):
				GameContext.gui.setHovered( result.collider )
			
			if( result.collider.is_in_group("GridMap") ):
				GameContext.gui.setHovered( result.collider )



