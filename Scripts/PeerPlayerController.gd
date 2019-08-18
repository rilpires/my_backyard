extends "res://Scenes/Controller_Character.gd"

const PlayerState = preload("res://Scripts/PlayerState.gd")

var my_state : PlayerState = null

func _ready():
	set_process_input(false)
	if( my_state == null ):
		print("PeerPlayerController without player_state")

func _process(delta):
	input_direction.y = 0
	if( (my_state.position - translation).length_squared() > 1.2 ):
		input_direction = (my_state.position - translation).normalized()
		input_direction.y = 0
		self.input_direction = input_direction
	else:
		self.input_direction = Vector3(0,0,0)
