extends "res://Scenes/Controller_Character.gd"

func _ready():
	set_process_input(true)


func _direction_changed(new_val):
	if( direction_tween and new_val.length_squared() > 0  ):
		var old_rotation_degrees = $Model.rotation_degrees
		var target_rotation_degrees = Vector3(0,0,0)
		target_rotation_degrees.y = 270 + atan2( new_val.z , -new_val.x ) * 180.0 / PI;
		while( abs(target_rotation_degrees.y - old_rotation_degrees.y) > 180 ):
			if(target_rotation_degrees.y > old_rotation_degrees.y):
				target_rotation_degrees.y -= 360
			else:
				target_rotation_degrees.y += 360
		direction_tween.stop_all()
		direction_tween.interpolate_property( $Model , "rotation_degrees" ,
		$Model.rotation_degrees , target_rotation_degrees , 0.7 , 
		Tween.TRANS_EXPO , Tween.EASE_OUT )
		direction_tween.start()

func _input(event):
	if( event.is_action("ui_left") or
	event.is_action("ui_right") or
	event.is_action("ui_up") or
	event.is_action("ui_down") ):
		if( not event.is_echo() ):
			input_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
			input_direction.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
			self.input_direction = input_direction