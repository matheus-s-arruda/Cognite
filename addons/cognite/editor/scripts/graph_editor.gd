@tool
extends GraphEdit


var create_opitions: OptionButton


func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		if create_opitions:
			create_opitions.show_popup()
			var popup: PopupMenu = create_opitions.get_popup()
			popup.set_position(create_opitions.get_global_mouse_position())
