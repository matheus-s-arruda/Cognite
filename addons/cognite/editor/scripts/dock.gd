@tool
class_name CogniteDock extends PanelContainer


@onready var percepition_list: PanelContainer = $dock/percepition_list
@onready var context_list: PanelContainer = $dock/context_list
@onready var decision_list: PanelContainer = $dock/decision_list
@onready var action_list: PanelContainer = $dock/action_list

@onready var create_perception_item: Button = $dock/percepition_list/VBoxContainer/PanelContainer/ScrollContainer/VBoxContainer/create_perception_item
@onready var create_context_item: Button = $dock/context_list/VBoxContainer/PanelContainer/ScrollContainer/VBoxContainer/create_perception_item
@onready var create_decision_item: Button = $dock/decision_list/VBoxContainer/PanelContainer/ScrollContainer/VBoxContainer/create_decision_item
@onready var create_new_action: MenuButton = $dock/action_list/VBoxContainer/PanelContainer/ScrollContainer/VBoxContainer/PanelContainer/create_new_action


var current_assemble: CogniteAssemble


func set_current_assemble(assemble: CogniteAssemble):
	current_assemble = assemble
	
	percepition_list.set_assemble(assemble)
	context_list.set_assemble(assemble)
	decision_list.set_assemble(assemble)
	action_list.set_assemble(assemble)
	
	create_perception_item.set_disabled(false)
	create_context_item.set_disabled(false)
	create_decision_item.set_disabled(false)
	create_new_action.set_disabled(false)
