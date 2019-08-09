extends RigidBody

var speed = 11
var input_direction = Vector3(0,0,0);

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	input_direction.x = lerp(
		input_direction.x , 
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left") ,
		0.2 )
	input_direction.z = lerp(
		input_direction.z , 
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up") ,
		0.2 )
	if( input_direction.length_squared() >= 1 ):
		input_direction = input_direction.normalized()
	if( input_direction.length_squared() > 0.1 ):
		$Model/Armature/AnimationPlayer.current_animation = "Walking"
		var look_target = global_transform.origin - input_direction
		$Model.look_at( look_target , Vector3(0,1,0) )
	else:
		$Model/Armature/AnimationPlayer.current_animation = "Standing"
	
func _integrate_forces(state):
	state.linear_velocity.x = input_direction.x * speed
	state.linear_velocity.z = input_direction.z * speed 


