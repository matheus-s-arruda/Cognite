@tool
extends HBoxContainer


var assemble: CogniteAssemble
var action_id: int
var deed_id: int
var deed_data: Dictionary

@onready var deed_name: LineEdit = $LineEdit
@onready var process_mode_button: MenuButton = $process_mode_button


func _ready() -> void:
	process_mode_button.get_popup().id_pressed.connect(_on_process_mode_button_pressed)


func load_deed(_assemble: CogniteAssemble, _action_id: int, _deed_id: int, _deed_data: Dictionary):
	assemble = _assemble; action_id = _action_id; deed_id = _deed_id; deed_data = _deed_data
	
	deed_name.text = deed_data.name
	process_mode_button.text = ["", "Cascade", "Parallel"][deed_data.process_mode]


func _on_line_edit_text_changed(new_text: String) -> void:
	var word := Cognite.filter_string(new_text, "[A-Za-z_]")
	var caret_position = deed_name.caret_column
	
	deed_name.set_text(word)
	deed_name.caret_column = caret_position
	deed_data.name = word
	assemble.atualize_deed(deed_id, deed_data)


func _on_up_pressed() -> void:
	var action := assemble.get_action(action_id)
	var p : int = action.deed_list.find(action_id)
	if p > 0:
		action.deed_list.remove_at(p)
		action.deed_list.insert(p-1, action_id)
		assemble.atualize_action(action_id, action)


func _on_down_pressed() -> void:
	var action := assemble.get_action(action_id)
	var p : int = action.deed_list.find(action_id)
	if p < action.deed_list.size() - 1:
		action.deed_list.remove_at(p)
		action.deed_list.insert(p+1, action_id)
		assemble.atualize_action(action_id, action)


func _on_process_mode_button_pressed(id: int):
	process_mode_button.text = ["", "Cascade", "Parallel"][id]
	deed_data.process_mode = id
	assemble.atualize_deed(deed_id, deed_data)


func _on_delete_pressed() -> void:
	var action := assemble.get_action(action_id)
	action.deed_list.erase(deed_id)
	assemble.deeds.erase(deed_id)
	assemble.actualize.call_deferred()
	queue_free()
