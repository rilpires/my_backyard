extends RigidBody

const Player = preload("res://Scripts/Player.gd")

var my_state : Player = null

func _ready():
	if( my_state == null ):
		queue_free()
	custom_integrator = true
	can_sleep = false

func _physics_process(delta):
	get_node("Model").rotation = lerp(get_node("Model").rotation, my_state.rotation,0.5)

func _integrate_forces(state):
	if( (my_state.position - translation).length() > 0.4 ):
		state.linear_velocity = (my_state.position - translation).normalized()*10
		get_node("Model/Armature/AnimationPlayer").play("Walking")
	else:
		state.linear_velocity = Vector3(0,0,0)
		get_node("Model/Armature/AnimationPlayer").play("Standing")