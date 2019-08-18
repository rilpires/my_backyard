extends RigidBody

var speed = 10

var input_direction = Vector3(0,0,0) setget setInputDirection

onready var anim_player = $Model/Armature/AnimationPlayer
onready var direction_tween = $DirectionTween

func _ready():
	custom_integrator = true
	can_sleep = false
	fixAnimations()
	playAnimationOnce("Waving")

func fixAnimations():
	var anim_player = get_node("Model/Armature/AnimationPlayer")
	for anim_name in anim_player.get_animation_list() :
		var anim = anim_player.get_animation(anim_name)
		anim.loop = (anim_name != "Waving")

func _input(event):
	if( event.is_action("ui_left") or
	event.is_action("ui_right") or
	event.is_action("ui_up") or
	event.is_action("ui_down") ):
		if( not event.is_echo() ):
			input_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
			input_direction.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
			self.input_direction = input_direction

func setInputDirection(new_val):
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
	
	if( new_val.length_squared() > 0 ):
		anim_player.play("Walking")
	elif( anim_player.current_animation == "Walking" ):
		anim_player.play("Standing")
	
	input_direction = new_val

func playAnimationOnce( anim_name ):
	anim_player.play(anim_name)
	anim_player.clear_queue()
	anim_player.queue("Standing")

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


