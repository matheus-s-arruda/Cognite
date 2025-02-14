@tool
extends CogniteGraphNode

@onready var line_edit: LineEdit = $LineEdit
@onready var bigger = $HBoxContainer2/bigger
@onready var smaller = $HBoxContainer/smaller


func _on_line_edit_text_changed(new_text: String) -> void:
	var caret_position = line_edit.caret_column
	var word := _filter_string(new_text)
	line_edit.set_text(word)
	
	line_edit.caret_column = caret_position
	assemble.nodes[id]["range"] = word
	assemble.actualize()


func set_data(data: Dictionary):
	if not is_ready:
		await ready
	
	if data.has("position"):
		position_offset = data.position
	
	if data.has("range"):
		line_edit.set_text(assemble.nodes[id]["range"])
	
	if assemble.nodes[id].has("bigger"):
		bigger.value = data.bigger
	else:
		assemble.nodes[id]["bigger"] = 1.0
	
	if assemble.nodes[id].has("smaller"):
		smaller.value = data.smaller
	else:
		assemble.nodes[id]["smaller"] = 0.0

func _on_bigger_value_changed(value):
	assemble.nodes[id]["bigger"] = value

func _on_smaller_value_changed(value):
	assemble.nodes[id]["smaller"] = value
