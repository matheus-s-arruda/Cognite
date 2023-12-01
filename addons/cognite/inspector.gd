@tool
extends EditorInspectorPlugin

var plugin: EditorPlugin
var main_panel: Control


func _can_handle(object: Object):
	if object.has_method("is_cognite_source"):
		return true
	
	elif object.has_method("is_cognite_assemble"):
		main_panel.show_editor(object)
		plugin.get_editor_interface().set_main_screen_editor("Cognite")
		return true
	
	elif object.has_method("is_cognite_node"):
		return true
	
	return false






