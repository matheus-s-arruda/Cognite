@tool
extends PanelContainer


var context_id: int
var decision_id: int
var assemble: CogniteAssemble

@onready var context_name: Label = $HBoxContainer/context_name
@onready var delete: Button = $HBoxContainer/delete


func load_context(_context_id: int, _decision_id: int, _assemble: CogniteAssemble):
	context_id = _context_id; decision_id = _decision_id; assemble = _assemble
	var context: Dictionary = assemble.get_context(context_id)
	context_name.text = context.name


func _on_delete_pressed() -> void:
	assemble.get_decision(decision_id).context_ids.erase(context_id)
	queue_free()
