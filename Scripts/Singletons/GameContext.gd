extends Node

const GameWorld = preload('res://Scripts/GameWorld.gd')
const Player = preload("res://Scripts/Player.gd")

var current_game_world : GameWorld = null
var my_player_state : Player = null
var gui = null
var main_root = null


func _init():
	current_game_world = GameWorld.new()

