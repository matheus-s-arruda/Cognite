extends EditorProperty

var option_button := OptionButton.new()
var updating := false

func _init():
	add_child(option_button)
	add_focusable(option_button)
	option_button.item_selected.connect(_on_item_selected)


func _update_property():
	var current_value = get_edited_object()[get_edited_property()]
	var target_path = get_edited_object().reference_path
	
	updating = true
	option_button.clear()
	
	if target_path and get_edited_object().has_node(target_path):
		var target_node = get_edited_object().get_node(target_path)
		var properties = target_node.get_property_list()
		
		for i in range(properties.size()):
			var p_name = properties[i]["name"]
			option_button.add_item(p_name)
			if p_name == current_value:
				option_button.select(i)
			
	updating = false


func _on_item_selected(index: int):
	if updating: return
	var selected_name = option_button.get_item_text(index)
	emit_changed(get_edited_property(), selected_name)
