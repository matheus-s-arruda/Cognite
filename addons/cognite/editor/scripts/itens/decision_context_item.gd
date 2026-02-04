@tool
extends PanelContainer

var context_id: int
var decision_id: int
var assemble: CogniteAssemble

@onready var context_name: Label = $HBoxContainer/context_name
@onready var delete: Button = $HBoxContainer/delete
@onready var score_value: LineEdit = $HBoxContainer/score_value


func load_context(_context_id: int, _decision_id: int, _assemble: CogniteAssemble):
	context_id = _context_id; decision_id = _decision_id; assemble = _assemble
	var context: Dictionary = assemble.get_context(context_id)
	var decision: Dictionary = assemble.get_decision(_decision_id)
	context_name.text = context.name
	score_value.text = str(decision.context_ids[context_id])


func _on_delete_pressed() -> void:
	assemble.get_decision(decision_id).context_ids.erase(context_id)
	queue_free()


func _on_score_value_text_changed(new_text: String) -> void:
	var word := Cognite.filter_string(new_text, "[-0-9]")
	var caret_position = score_value.caret_column
	
	score_value.set_text(word)
	score_value.caret_column = caret_position
	
	var decision := assemble.get_decision(decision_id)
	decision.context_ids[context_id] = int(word)
	
	assemble.atualize_decision(decision_id, decision)
