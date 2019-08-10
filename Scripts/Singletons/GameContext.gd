extends Node

const GameWorld = preload('res://Scripts/GameWorld.gd')

var current_game_world : GameWorld = null

func _init():
	current_game_world = GameWorld.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	if( current_game_world ):
		print("tem game world")
	else:
		print("nao tem game world!")
