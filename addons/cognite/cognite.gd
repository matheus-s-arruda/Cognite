@tool
class_name Cognite extends EditorPlugin

var bottom_panel: Control
var inspector: EditorInspectorPlugin


func _enter_tree():
	bottom_panel = preload("res://addons/cognite/editor/cognite_editor.tscn").instantiate()
	inspector = preload("res://addons/cognite/inspetor/inspector.gd").new()
	
	inspector.bottom_panel = bottom_panel
	inspector.plugin = self
	
	EditorInterface.get_file_system_dock().file_removed.connect(inspector.is_resource_deleted)
	
	add_custom_type( "CogniteNode", "Node",
			preload("res://addons/cognite/cognite_node.gd"),
			preload("res://addons/cognite/assets/brain.svg")
	)
	add_control_to_bottom_panel(bottom_panel, "Cognite")
	add_inspector_plugin(inspector)


func _exit_tree():
	remove_control_from_bottom_panel(bottom_panel)
	remove_inspector_plugin(inspector)
	remove_custom_type("CogniteNode")


func file_removed(file: String):
	inspector.is_resource_deleted(file)
