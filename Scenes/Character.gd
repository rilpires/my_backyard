extends RigidBody

var speed = 10
var input_direction = Vector3(0,0,0);

func _ready():
	var anim_player = get_node("Model/Armature/AnimationPlayer")
	for anim_name in anim_player.get_animation_list() :
		var anim = anim_player.get_animation(anim_name)
		anim.loop = true

func _input(event):
	if( event.is_action("ui_left") or
	event.is_action("ui_right") or
	event.is_action("ui_up") or
	event.is_action("ui_down") ):
		if( not event.is_echo() ):
			input_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
			input_direction.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
			
			var anim_player = $Model/Armature/AnimationPlayer
			if( input_direction.length_squared() > 0 ):
				anim_player.play("Walking")
				var look_target = global_transform.origin - input_direction
				$Model.look_at( look_target , Vector3(0,1,0) )
			else:
				anim_player.play("Standing")

func stop():
	var anim_player = $Model/Armature/AnimationPlayer
	anim_player.play("Standing")
	input_direction = Vector3(0,0,0)

func _integrate_forces(state):
	var velocity = input_direction
	if( velocity.length_squared() > 0 ):
		velocity = input_direction.normalized() * speed
	state.linear_velocity.x = velocity.x
	state.linear_velocity.z = velocity.z 


