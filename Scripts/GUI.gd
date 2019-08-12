extends Control

var current_hovered = null setget setHovered

func _init():
	GameContext.gui = self
func _ready():
	pass

func setHovered( obj ):
	return