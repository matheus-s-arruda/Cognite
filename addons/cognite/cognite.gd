@tool
extends EditorPlugin

const DOCK = preload("uid://bukcku74rrx3f")
var selector: EditorSelection
var inspector: EditorInspectorPlugin
var dock: Control


func _enter_tree():
	inspector = preload("res://addons/cognite/inspector.gd").new()
	add_inspector_plugin(inspector)
	
	dock = preload("res://addons/cognite/editor/dock.tscn").instantiate()
	add_control_to_bottom_panel(dock, "Cognite")
	
	add_custom_type( "CogniteNode", "Node",
			preload("res://addons/cognite/node/cognite_node.gd"),
			preload("res://addons/cognite/assets/brain.svg"))
	
	selector = EditorInterface.get_selection()
	selector.selection_changed.connect(_on_selection_changed)


func _exit_tree():
	remove_inspector_plugin(inspector)
	remove_control_from_bottom_panel(dock)
	remove_custom_type("CogniteNode")
	inspector.free()
	dock.free()

func _get_plugin_name():
	return "Cognite"

func _get_plugin_icon():
	return preload("res://addons/cognite/assets/brain.svg")


func _on_selection_changed():
	var nodes_selecionados = selector.get_selected_nodes()
	
	if nodes_selecionados.size() > 0:
		var primeiro_node = nodes_selecionados[0]
		# Envia o nome do node selecionado para a função na nossa Label
		dock.atualize(primeiro_node)
	else:
		dock.hide_containers()
