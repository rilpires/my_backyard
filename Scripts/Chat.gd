extends NinePatchRect

onready var line_edit = $InputTextRect/LineEdit
onready var chat_log = $RichTextLabel

func _ready():
	line_edit.connect("focus_entered",self,"_line_edit_focus_entered")
	line_edit.connect("focus_exited",self,"_line_edit_focus_exited")

func _line_edit_focus_entered():
	for player in get_tree().get_nodes_in_group("Player"):
		player.stop()
		player.set_process_input( false )

func _line_edit_focus_exited():
	for player in get_tree().get_nodes_in_group("Player"):
		player.set_process_input( true )

func _input(event):
	if( event is InputEventKey and event.is_pressed() and not event.is_echo() and event.scancode == KEY_ENTER ):
		if( line_edit.has_focus() ):
			line_edit.release_focus()
			if( line_edit.text.length() > 200 ):
				line_edit.text = line_edit.text.substr(0,200)
			if( line_edit.text.length() > 0 ): 
				addPlayerMessage( "red","Local",line_edit.text)
			line_edit.text = ""
		else:
			line_edit.grab_focus()
		

func addPlayerMessage( color , name , message ):
	var time = OS.get_time()
	var time_string = var2str(time.hour) + ":" + var2str(time.minute) + ":" + var2str(time.second)
	var string = "[color="+color+"][" + time_string + " " + name + "]:[/color] " + message
	chat_log.append_bbcode( string )
	chat_log.newline()
