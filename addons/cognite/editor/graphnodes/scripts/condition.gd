@tool
extends CogniteGraphNode

@onready var line_edit: LineEdit = $LineEdit


func set_data(data: Dictionary):
	if not is_ready:
		await ready
	
	if data.has("position"):
		position_offset = data.position
	
	if data.has("condition"):
		line_edit.set_text(data.condition)


func _on_line_edit_text_changed(new_text: String) -> void:
	var caret_position = line_edit.caret_column
	var word := _filter_string(new_text)
	line_edit.set_text(word)
	
	line_edit.caret_column = caret_position
	assemble.nodes[id]["condition"] = word
	assemble.actualize()
