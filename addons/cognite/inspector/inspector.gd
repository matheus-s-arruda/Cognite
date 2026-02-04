@tool
extends EditorInspectorPlugin

func _can_handle(object: Object):
	if object is CogniteAssemble: return true

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if object is CogniteAssemble:
		return (
			name == "creation_count"
			or name == "perceptions"
			or name == "contexts"
			or name == "decisions"
			or name == "actions"
			or name == "deeds"
			or name == "perception_runtime_value"
		)
