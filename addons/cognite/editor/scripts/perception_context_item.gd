@tool
extends PanelContainer

const FilterString := {
	TYPE_INT: "[0-9]",
	TYPE_FLOAT: "[0-9.]"
}

var id: int
var context_id: int
var type: Variant.Type
var assemble: CogniteAssemble

@onready var property_name: Label = $HBoxContainer/property_name
@onready var min: LineEdit = $HBoxContainer/min
@onready var max: LineEdit = $HBoxContainer/max
@onready var boolean: CheckButton = $HBoxContainer/boolean


func load_perception(perception_id: int, _context_id: int, context_perception: Dictionary, _assemble: CogniteAssemble):
	id = perception_id; context_id = _context_id; assemble = _assemble
	
	var perception: Array = assemble.get_perception(id)
	var is_bool: bool = bool(perception[1] == 1)
	type = perception[1]
	
	property_name.text = perception[0]
	boolean.set_visible(is_bool)
	min.set_visible(!is_bool)
	max.set_visible(!is_bool)
	
	if !is_bool:
		if context_perception.min:
			min.text = str(int(context_perception.min) if type == TYPE_INT else context_perception.min)
			
		if context_perception.max:
			max.text = str(int(context_perception.max) if type == TYPE_INT else context_perception.max)
	else:
		boolean.set_pressed_no_signal(context_perception.boolean)


func _on_min_text_changed(new_text: String) -> void:
	var caret_position = min.caret_column
	var word := Cognite.filter_string(new_text, FilterString[type])
	min.set_text(word)
	min.caret_column = caret_position
	
	var floating := float(word)
	var context: Dictionary = assemble.get_context(context_id)
	context.perception_ids[id].min = floating
	assemble.atualize_context(context_id, context)


func _on_max_text_changed(new_text: String) -> void:
	var caret_position = max.caret_column
	var word := Cognite.filter_string(new_text, FilterString[type])
	max.set_text(word)
	max.caret_column = caret_position
	
	var floating := float(word)
	var context: Dictionary = assemble.get_context(context_id)
	context.perception_ids[id].max = floating
	assemble.atualize_context(context_id, context)


func _on_boolean_toggled(toggled_on: bool) -> void:
	var context: Dictionary = assemble.get_context(context_id)
	context.perception_ids[id].boolean = toggled_on
	assemble.atualize_context(context_id, context)


func _on_delete_pressed() -> void:
	var context: Dictionary = assemble.get_context(context_id)
	context.perception_ids.erase(id)
	assemble.atualize_context(context_id, context)
	queue_free()
