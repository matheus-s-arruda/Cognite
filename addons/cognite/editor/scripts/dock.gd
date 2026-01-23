@tool
class_name CogniteDock extends MarginContainer


@onready var percepition_list: PanelContainer = $dock/percepition_list
@onready var context_list: PanelContainer = $dock/context_list

var current_assemble: CogniteAssemble


func set_current_assemble(assemble: CogniteAssemble):
	current_assemble = assemble
	
	percepition_list.set_assemble(assemble)
	context_list.set_assemble(assemble)
