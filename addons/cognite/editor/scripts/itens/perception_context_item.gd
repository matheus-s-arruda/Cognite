@tool
extends PanelContainer

var id: int
var context_id: int
var context: Dictionary
var perception_data: Dictionary
var assemble: CogniteAssemble

@onready var property_name: Label = $VBoxContainer/HBoxContainer/property_name
@onready var proper: HBoxContainer = $VBoxContainer/proper
@onready var boolean: CheckButton = $VBoxContainer/proper/boolean
@onready var min: LineEdit = $VBoxContainer/proper/min
@onready var max: LineEdit = $VBoxContainer/proper/max
@onready var text: LineEdit = $VBoxContainer/proper/text
@onready var perception_type: Label = $VBoxContainer/proper/property_name


func load_perception(perception_id: int, _perception_data: Dictionary, _context_id: int, _assemble: CogniteAssemble):
	id = perception_id; perception_data = _perception_data; context_id = _context_id; assemble = _assemble
	var perception: Array = assemble.get_perception(id)
	context = assemble.get_context(context_id)
	property_name.text = perception[0]
	perception_data = context.perception_ids[id]
	
	match perception[1]:
		0:
			boolean.set_pressed_no_signal(perception_data.bool)
			perception_type.text = "Boolean"
			boolean.show()
		1:
			min.text = str(perception_data.min); min.show()
			max.text = str(perception_data.max); max.show()
			perception_type.text = "Numeric"
		2:
			text.text = str(perception_data.text)
			perception_type.text = "String"
			text.show()


func _on_delete_pressed() -> void:
	var context: Dictionary = assemble.get_context(context_id)
	context.perception_ids.erase(id)
	assemble.atualize_context(context_id, context)
	queue_free()


func _on_show_property_toggled(toggled_on: bool) -> void:
	proper.visible = toggled_on


func _on_check_button_toggled(toggled_on: bool) -> void:
	perception_data.bool = toggled_on
	assemble.atualize_context(context_id, context)


func _on_min_text_changed(new_text: String) -> void:
	var caret_position = min.caret_column
	var word := Cognite.filter_string(new_text, "[0-9.]")
	min.set_text(word)
	min.caret_column = caret_position
	perception_data.min = float(word)
	assemble.atualize_context(context_id, context)


func _on_max_text_changed(new_text: String) -> void:
	var caret_position = max.caret_column
	var word := Cognite.filter_string(new_text, "[0-9.]")
	max.set_text(word)
	max.caret_column = caret_position
	perception_data.max = float(word)
	assemble.atualize_context(context_id, context)


func _on_text_text_changed(new_text: String) -> void:
	var caret_position = text.caret_column
	var word := Cognite.filter_string(new_text, "[a-zA-Z_]")
	text.set_text(word)
	text.caret_column = caret_position
	perception_data.text = str(word)
	assemble.atualize_context(context_id, context)
