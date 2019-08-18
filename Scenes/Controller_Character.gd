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
	if( direction_tween ):
		direction_tween.connect("tween_completed" , self , "_tween_completed" )

func fixAnimations():
	var anim_player = get_node("Model/Armature/AnimationPlayer")
	for anim_name in anim_player.get_animation_list() :
		var anim = anim_player.get_animation(anim_name)
		anim.loop = (anim_name != "Waving")

func setInputDirection(new_val):
	if( new_val.length_squared() > 0 ):
		anim_player.play("Walking")
	elif( anim_player.current_animation == "Walking" ):
		anim_player.play("Standing")
	if( has_method("_direction_changed") ):
		call("_direction_changed" , new_val )
	input_direction = new_val

func _tween_completed( obj , key ):
	$Model.rotation_degrees.y = int($Model.rotation_degrees.y)%360

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


