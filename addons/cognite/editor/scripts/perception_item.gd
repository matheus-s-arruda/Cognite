@tool
extends HBoxContainer

const VALUE_TYPE_TEXT: PackedStringArray = ["type", "bool", "int", "float"]

@onready var property_name: LineEdit = $property_name
@onready var menu_button: MenuButton = $PanelContainer/MenuButton

var property_type: Variant.Type
var Assemble: CogniteAssemble
var assemble_perception_id: int


func _ready() -> void:
	menu_button.get_popup().id_pressed.connect(_on_menu_button_pressed)
	property_name.text_changed.connect(_property_name_text_changed)


func load_property(perception: Array):
	property_name.set_text(perception[0])
	property_type = perception[1]
	menu_button.set_button_icon(Cognite.get_theme_icon(VALUE_TYPE_TEXT[property_type]))


func _property_name_text_changed(new_text: String):
	var caret_position = property_name.caret_column
	var word := Cognite.filter_string(new_text, "[A-Za-z_]")
	property_name.set_text(word)
	property_name.caret_column = caret_position
	Assemble.perceptions[assemble_perception_id][0] = word
	Assemble.actualize()


func _on_menu_button_pressed(id : int) -> void:
	if Assemble.perceptions.has(id):
		property_type = id
		menu_button.set_button_icon(Cognite.get_theme_icon(VALUE_TYPE_TEXT[property_type]))
		Assemble.perceptions[assemble_perception_id][1] = id
		Assemble.actualize()


func _on_delete_pressed() -> void:
	Assemble.perceptions.erase(assemble_perception_id)
	Assemble.actualize.call_deferred()
	queue_free()
