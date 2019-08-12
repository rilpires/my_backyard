extends Node

const GameWorld = preload('res://Scripts/GameWorld.gd')

var current_game_world = null
var gui = null
var main_root = null

func _init():
	current_game_world = GameWorld.new()

