@tool
class_name Cognite extends EditorPlugin


var inspector: EditorInspectorPlugin
static var editor_theme: Theme
var main_panel: Control


func _enter_tree():
	inspector = preload("res://addons/cognite/inspector/inspector.gd").new()
	add_inspector_plugin(inspector)
	
	main_panel = preload("res://addons/cognite/editor/dock.tscn").instantiate()
	main_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	get_editor_interface().get_editor_main_screen().add_child(main_panel)
	_make_visible(false)
	
	add_custom_type( "CogniteNode", "Node", preload("res://addons/cognite/node/cognite_node.gd"), preload("res://addons/cognite/assets/brain.svg"))
	editor_theme = get_editor_interface().get_editor_theme()


static func get_theme_icon(icon_name: String) -> Texture2D:
	return editor_theme.get_icon(icon_name, "EditorIcons")


func _exit_tree():
	remove_custom_type("CogniteNode")
	remove_inspector_plugin(inspector)
	inspector.free()
	
	if is_instance_valid(main_panel):
		main_panel.queue_free()


#region MAIN PANEL
func _has_main_screen():
	return true

func _make_visible(visible: bool):
	if main_panel:
		main_panel.visible = visible

func _get_plugin_name():
	return "Cognite"

func _get_plugin_icon():
	return preload("res://addons/cognite/assets/brain.svg")
#endregion


static func filter_string(string: String, filter: String) -> String:
	var word = ''
	var regex = RegEx.new()
	regex.compile(filter) #("[A-Za-z0-9_]")
	
	for valid_character in regex.search_all(string):
		word += valid_character.get_string()
	return word
