@tool
extends PanelContainer

var id: int
var context_id: int
var assemble: CogniteAssemble

@onready var property_name: Label = $HBoxContainer/property_name
@onready var score: LineEdit = $HBoxContainer/score


func load_perception(perception_id: int, _context_id: int, _score: int, _assemble: CogniteAssemble):
	id = perception_id; context_id = _context_id; assemble = _assemble
	
	var perception: Dictionary = assemble.get_perception(perception_id)	
	property_name.text = perception.name
	score.text = str(_score)


func _on_score_text_changed(new_text: String) -> void:
	var caret_position = score.caret_column
	var word := Cognite.filter_string(new_text, "[0-9]")
	score.set_text(word)
	score.caret_column = caret_position
	
	var context: Dictionary = assemble.get_context(context_id)
	context.perception_ids[id] = int(word)
	assemble.atualize_context(context_id, context)


func _on_delete_pressed() -> void:
	var context: Dictionary = assemble.get_context(context_id)
	context.perception_ids.erase(id)
	assemble.atualize_context(context_id, context)
	queue_free()
