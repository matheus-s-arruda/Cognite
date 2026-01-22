@tool
extends EditorInspectorPlugin

var button_create_assemble := Button.new()
var popup_file: EditorFileDialog


func _can_handle(object: Object):
	if object is CogniteAssemble or object is CogniteNode: return true


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	#if object is CogniteNode:
		#if name == "cognite_assemble":
			#
			#
			#return true
	
	
	if object is CogniteAssemble:
		if name == "nodes":
			return true
