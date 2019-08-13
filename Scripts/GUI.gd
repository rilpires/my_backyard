extends Control

var current_hovered = null setget setHovered
onready var chat_log = $Chat

func _init():
	GameContext.gui = self
func _ready():
	pass

func setHovered( obj ):
	return