@tool
extends PanelContainer

const VALUE_TYPE_TEXT: PackedStringArray = ["boolean", "float - int", "string"]

var type: int
var Assemble: CogniteAssemble
var assemble_perception_id: int

@onready var property_name: LineEdit = $perception_item/HBoxContainer/property_name
@onready var property_type_button: MenuButton = $perception_item/HBoxContainer/PanelContainer/property_type


func _ready() -> void:
	property_type_button.get_popup().id_pressed.connect(_property_type_button_pressed)
	property_name.text_changed.connect(_property_name_text_changed)


func load_property(perception_id: int, assemble: CogniteAssemble):
	assemble_perception_id = perception_id; Assemble = assemble
	var property: Array = Assemble.get_perception(perception_id)
	property_name.set_text(property[0])
	property_type_button.text = VALUE_TYPE_TEXT[property[1]]
	type = property[1]


func _property_name_text_changed(new_text: String):
	var caret_position = property_name.caret_column
	var word := Cognite.filter_string(new_text, "[A-Za-z_]")
	property_name.set_text(word)
	property_name.caret_column = caret_position
	Assemble.atualize_perception(assemble_perception_id, word, type)


func _property_type_button_pressed(id : int) -> void:
	type = id
	property_type_button.text = VALUE_TYPE_TEXT[id]
	Assemble.atualize_perception(assemble_perception_id, property_name.text, type)


func _on_delete_pressed() -> void:
	Assemble.perceptions.erase(assemble_perception_id)
	Assemble.actualize.call_deferred()
	queue_free()
