@tool
extends EditorInspectorPlugin

const INSPECTOR_INITIAL_STATE = preload("res://addons/cognite/editor/inspector_initial_state.tscn")

var plugin: EditorPlugin
var main_panel: Control
var initial_state: Control


func _can_handle(object: Object):
	if object.has_method("is_cognite_assemble"):
		main_panel.show_editor(object)
		plugin.get_editor_interface().set_main_screen_editor("Cognite")
		return true
	
	elif object.has_method("is_cognite_node"):
		return true
	
	return false


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if object is CogniteAssemble:
		if name == "nodes":
			return true
	
	if object is CogniteNode:
		if name == "initial_state":
			if not object.cognite_assemble_root:
				return true
			
			initial_state = INSPECTOR_INITIAL_STATE.instantiate()
			initial_state.cognite_node = object
			
			var btn: OptionButton = initial_state.get_node("opitions")
			
			for item in object.cognite_assemble_root.get_states():
				btn.add_item(item)
			
			btn.item_selected.connect(object.set_initial_state)
			btn.selected = object.initial_state
			
			add_property_editor(name, initial_state)
			return true
