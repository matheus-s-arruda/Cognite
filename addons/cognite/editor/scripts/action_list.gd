@tool
extends PanelContainer

const ACTION_ITEM = preload("uid://5ryiecwquvgd")

var assemble: CogniteAssemble
var action_list: Array[Control]

@onready var create_new_action: MenuButton = $VBoxContainer/PanelContainer/ScrollContainer/VBoxContainer/PanelContainer/create_new_action
@onready var action_list_panel: VBoxContainer = $VBoxContainer/PanelContainer/ScrollContainer/VBoxContainer


func _ready() -> void:
	create_new_action.get_popup().id_pressed.connect(_on_create_new_action_menu_pressed)


func set_assemble(_assemble: CogniteAssemble):
	assemble= _assemble
	
	for button in action_list:
		if button: button.queue_free()
	action_list.clear()
	
	for action_id in assemble.actions:
		create_decision_item(action_id, assemble.actions[action_id])


func create_decision_item(action_id: int, action: Dictionary):
	var act = ACTION_ITEM.instantiate()
	action_list_panel.add_child(act)
	action_list.append(act)
	act.load_action(assemble, action_id, action)


func _on_create_new_action_menu_pressed(id: int):
	var create_action := assemble.create_action(id)
	create_decision_item(create_action[0], create_action[1])


func _on_create_new_action_pressed() -> void:
	create_new_action.get_popup().clear()
	create_new_action.get_popup().add_item("Decisions", 0)
	create_new_action.get_popup().set_item_as_separator(0, true)
	create_new_action.get_popup().set_item_disabled(0, true)
	
	for decisions_id in assemble.decisions:
		var decisions: Dictionary = assemble.decisions[decisions_id]
		create_new_action.get_popup().add_item(decisions.name, decisions_id)
