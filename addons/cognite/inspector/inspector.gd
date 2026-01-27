@tool
extends EditorInspectorPlugin

const BUTTON_BAKE = preload("res://addons/cognite/inspector/button_bake.tscn")

var button_create_assemble := Button.new()
var popup_file: EditorFileDialog


func _can_handle(object: Object):
	if object is CogniteAssemble or object is CogniteNode: return true


func _parse_begin(object: Object) -> void:
	if object is CogniteNode:
		if object.cognite_assemble == null: return
		
		var bake_button := BUTTON_BAKE.instantiate()
		(bake_button.get_child(0) as Button).pressed.connect(bake_assemble.bind(object))
		add_custom_control(bake_button)


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if object is CogniteAssemble:
		if name == "creation_count" or name == "perceptions" or name == "contexts" or name == "decisions":
			return true


func bake_assemble(cognite: CogniteNode):
	pass
