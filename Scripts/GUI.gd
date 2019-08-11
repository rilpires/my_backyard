extends CanvasLayer

var current_hovered = null setget setHovered

# Called when the node enters the scene tree for the first time.
func _ready():
	GameContext.gui = self

func setHovered( obj ):
	current_hovered = obj
	if( obj ):
		$Control/MousePosition.showPanel( obj.name )
	else:
		$Control/MousePosition.closePanel()