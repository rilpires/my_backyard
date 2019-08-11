tool
extends NinePatchRect

export (String) var text setget setText
export (bool) var fixed_width
export (int,"GROW_UP","GROW_DOWN") var grow_direction = 0
export (int) var label_margin_left = 5
export (int) var label_margin_right = 5
export (int) var label_margin_top = 5
export (int) var label_margin_bottom = 5


func _ready():
	if( has_node("Label") ):
		get_node("Label").connect("resized",self,"label_resized")
		setText(text)

func setText(new_val):
	if(!has_node("Label")): 
		return
	var label = $Label
	if(!new_val): 
		new_val = ""
	text = new_val
	if( fixed_width ):
		label.rect_size = Vector2( rect_min_size.x - label_margin_left - label_margin_right , 0)
		label.autowrap = true
		label.align = Label.ALIGN_CENTER
		label.text = new_val
		rect_pivot_offset = rect_min_size * 0.5
	
	else:
		label.autowrap = false
		label.align = Label.ALIGN_LEFT
		label.text = ""
		label.rect_size = Vector2( 0 , 0)
		label.text = new_val
	
	label.rect_position = Vector2(label_margin_left,label_margin_top)
	

func label_resized():
	var label = $Label
	var old_size_y = rect_min_size.y
	rect_min_size = label.rect_size + Vector2( label_margin_left + label_margin_right , label_margin_bottom + label_margin_top )
	rect_size = rect_min_size
	rect_pivot_offset = rect_size * 0.5
	if( fixed_width and grow_direction == 0 ):
		rect_position.y += (old_size_y - rect_min_size.y )





