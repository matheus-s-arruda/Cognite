@tool
extends EditorInspectorPlugin

var button_create_assemble := Button.new()
var popup_file: EditorFileDialog


func _can_handle(object: Object):
	if object is CogniteAssemble or object is CogniteNode: return true

func _parse_begin(object: Object) -> void:
	if object is CogniteNode:
		var btn = Button.new()
		btn.pressed.connect(object.recalcule_action_signals)
		add_custom_control(btn)

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if object is CogniteAssemble:
		return (
			name == "creation_count"
			or name == "perceptions"
			or name == "contexts"
			or name == "decisions"
			or name == "actions"
			or name == "deeds"
		)
