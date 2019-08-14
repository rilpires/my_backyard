extends Node

const GameWorld = preload('res://Scripts/GameWorld.gd')
const PlayerState = preload("res://Scripts/PlayerState.gd")

var current_game_world : GameWorld = null
var my_player_state : PlayerState = null
var gui = null
var main_root = null


func _init():
	current_game_world = GameWorld.new()
	my_player_state = PlayerState.new(null)

