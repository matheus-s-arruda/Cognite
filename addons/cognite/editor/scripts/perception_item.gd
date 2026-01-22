@tool
extends HBoxContainer

const VALUE_TYPE_TEXT: PackedStringArray = ["type", "bool", "int", "float"]
const FILTER_TYPE_TEXT: PackedStringArray = ["null", "", "[0-9_]", "[0-9._]"]

@onready var property_name: LineEdit = $property_name
@onready var menu_button: MenuButton = $MenuButton

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
	var word := _filter_string(new_text, "[A-Za-z0-9_]")
	property_name.set_text(word)
	property_name.caret_column = caret_position
	Assemble.perceptions[assemble_perception_id][0] = word
	Assemble.actualize()


func _on_menu_button_pressed(id : int) -> void:
	property_type = id
	menu_button.set_button_icon(Cognite.get_theme_icon(VALUE_TYPE_TEXT[property_type]))
	Assemble.perceptions[assemble_perception_id][1] = id
	Assemble.actualize()


func _filter_string(string: String, filter: String) -> String:
	var word = ''
	var regex = RegEx.new()
	regex.compile(filter) #("[A-Za-z0-9_]")
	
	for valid_character in regex.search_all(string):
		word += valid_character.get_string()
	return word
