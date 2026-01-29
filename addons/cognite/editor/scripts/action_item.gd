@tool
extends PanelContainer

const DEED_ITEM = preload("uid://d56kl0ah7k1r")

var assemble: CogniteAssemble
var action_id: int
var action_data: Dictionary
var deed_list: Array[Control]

@onready var context_name: LineEdit = $VBoxContainer/HBoxContainer/context_name
@onready var deed_panel: PanelContainer = $VBoxContainer/PanelContainer
@onready var deed_list_panel: VBoxContainer = $VBoxContainer/PanelContainer/deed_list


func load_action(_assemble: CogniteAssemble, _action_id: int, _action_data: Dictionary):
	assemble = _assemble; action_id = _action_id; action_data = _action_data
	
	var desicion := assemble.get_decision(action_data.decision_id)
	if not desicion.is_empty():
		context_name.text = desicion.name
	
	for item in deed_list:
		item.queue_free()
	deed_list.clear()
	
	for deed_id in action_data.deed_list:
		var deed := assemble.get_deed(deed_id)
		if not deed.is_empty():
			create_deed(deed_id, deed)


func create_deed(deed_id: int, deed_data: Dictionary):
	var deed = DEED_ITEM.instantiate()
	deed_list_panel.add_child(deed)
	deed.load_deed(assemble, action_id, deed_id, deed_data)
	deed_list.append(deed)


func _on_activated_toggled(toggled_on: bool) -> void:
	action_data.activated = toggled_on
	assemble.atualize_action(action_id, action_data)


func _on_delete_pressed() -> void:
	assemble.actions.erase(action_id)
	assemble.actualize.call_deferred()
	queue_free()


func _on_show_perception_list_toggled(toggled_on: bool) -> void:
	deed_panel.set_visible(toggled_on)


func _on_create_deed_pressed() -> void:
	var new_deed := assemble.create_deed()
	action_data.deed_list.append(new_deed[0])
	assemble.atualize_action(action_id, action_data)
	create_deed(new_deed[0], new_deed[1])
