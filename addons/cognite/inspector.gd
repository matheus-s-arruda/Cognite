@tool
extends EditorInspectorPlugin


static var baet


func _can_handle(object: Object):
	if object is CogniteAssemble: return true


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if object is CogniteAssemble:
		if name == "nodes":
			return true
