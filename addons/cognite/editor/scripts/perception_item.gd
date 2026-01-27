@tool
extends PanelContainer

enum PropertyType {BOOL, EQUAL, LESS, MORE, BETWEEN}
const VALUE_TYPE_TEXT: PackedStringArray = ["boolean", "equal to", "less than", "more than", "between"]


var property: Dictionary
var Assemble: CogniteAssemble
var assemble_perception_id: int

@onready var property_name: LineEdit = $perception_item/HBoxContainer/property_name
@onready var proper: HBoxContainer = $perception_item/proper
@onready var property_type_button: MenuButton = $perception_item/proper/PanelContainer/property_type
@onready var check_button: CheckButton = $perception_item/proper/CheckButton
@onready var line_edit: LineEdit = $perception_item/proper/LineEdit
@onready var line_edit_2: LineEdit = $perception_item/proper/LineEdit2


func _ready() -> void:
	property_type_button.get_popup().id_pressed.connect(_property_type_button_pressed)
	property_name.text_changed.connect(_property_name_text_changed)


func load_property(perception_id: int, assemble: CogniteAssemble):
	assemble_perception_id = perception_id; Assemble = assemble
	property = Assemble.get_perception(perception_id)
	property_name.set_text(property.name)
	property_type_button.text = VALUE_TYPE_TEXT[property.type]
	switch_button_types()


func switch_button_types():
	check_button.hide()
	line_edit.hide()
	line_edit_2.hide()
	
	match property.type:
		PropertyType.BOOL:
			check_button.set_pressed_no_signal(bool(property.prop1))
			check_button.show()
			
		PropertyType.EQUAL, PropertyType.LESS, PropertyType.MORE:
			line_edit.text = str(property.prop1)
			line_edit.show()
		
		PropertyType.BETWEEN:
			line_edit.text = str(property.prop1)
			line_edit_2.text = str(property.prop2)
			line_edit.show()
			line_edit_2.show()


func _on_show_property_toggled(toggled_on: bool) -> void:
	proper.set_visible(toggled_on)


func _property_name_text_changed(new_text: String):
	var caret_position = property_name.caret_column
	var word := Cognite.filter_string(new_text, "[A-Za-z_]")
	property_name.set_text(word)
	property.name = word
	property_name.caret_column = caret_position
	Assemble.atualize_perception(assemble_perception_id, property)
#
#
func _property_type_button_pressed(id : int) -> void:
	property_type_button.text = VALUE_TYPE_TEXT[id]
	property.type = id
	switch_button_types()
	Assemble.atualize_perception(assemble_perception_id, property)


func _on_delete_pressed() -> void:
	Assemble.perceptions.erase(assemble_perception_id)
	Assemble.actualize.call_deferred()
	queue_free()


func _on_check_button_toggled(toggled_on: bool) -> void:
	property.prop1 = int(toggled_on)
	Assemble.atualize_perception(assemble_perception_id, property)


func _on_line_edit_text_changed(new_text: String) -> void:
	var caret_position = line_edit.caret_column
	var word := Cognite.filter_string(new_text, "[-0-9.]")
	line_edit.set_text(word)
	property.prop1 = int(word)
	line_edit.caret_column = caret_position
	Assemble.atualize_perception(assemble_perception_id, property)


func _on_line_edit_2_text_changed(new_text: String) -> void:
	var caret_position = line_edit_2.caret_column
	var word := Cognite.filter_string(new_text, "[-0-9.]")
	line_edit_2.set_text(word)
	property.prop2 = int(word)
	line_edit_2.caret_column = caret_position
	Assemble.atualize_perception(assemble_perception_id, property)
