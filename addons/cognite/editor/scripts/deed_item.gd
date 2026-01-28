@tool
extends HBoxContainer


var assemble: CogniteAssemble
var action_id: int
var deed_id: int

@onready var deed_name: LineEdit = $LineEdit


func load_deed(_assemble: CogniteAssemble, _action_id: int, _deed_id: int):
	assemble = _assemble; action_id = _action_id; deed_id = _deed_id
	
	deed_name.text = assemble.deeds[deed_id]


func _on_line_edit_text_changed(new_text: String) -> void:
	var word := Cognite.filter_string(new_text, "[A-Za-z_]")
	var caret_position = deed_name.caret_column
	
	deed_name.set_text(word)
	deed_name.caret_column = caret_position
	assemble.deeds[deed_id] = word
	assemble.actualize()


func _on_up_pressed() -> void:
	var action := assemble.get_action(action_id)
	var p : int = action.deed_list.find(action_id)
	if p > 0:
		action.deed_list.remove_at(p)
		action.deed_list.insert(p-1, action_id)
		assemble.actualize()


func _on_down_pressed() -> void:
	var action := assemble.get_action(action_id)
	var p : int = action.deed_list.find(action_id)
	if p < action.deed_list.size - 1:
		action.deed_list.remove_at(p)
		action.deed_list.insert(p+1, action_id)
		assemble.actualize()


func _on_delete_pressed() -> void:
	var action := assemble.get_action(action_id)
	action.deed_list.erase(deed_id)
	assemble.actualize()
	queue_free()
