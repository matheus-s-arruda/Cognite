@tool
extends EditorInspectorPlugin

const DOOR_COMPOSE := preload("res://addons/cognite/inspetor/door_compose.tscn")
const STYLEBOX := preload("res://addons/cognite/assets/button_inspetor.stylebox")
const BUTTON_ASSEMBLY := preload("res://addons/cognite/inspetor/button_assembly.tscn")

var plugin: EditorPlugin
var bottom_panel: Control

var last_resource: CogniteAssemble


func _can_handle(object: Object):
	if object.has_method("is_cognite_source"):
		return true
	
	elif object.has_method("is_cognite_assemble"):
		last_resource = object
		bottom_panel.show_editor(object)
		plugin.make_bottom_panel_item_visible(bottom_panel)
		return true
	
	elif object.has_method("is_cognite_node"):
		return true
	
	return false


func _parse_begin(object):
	if object.has_method("is_cognite_node"):
		var button := BUTTON_ASSEMBLY.instantiate()
		button.get_child(0).pressed.connect(cognite_assembly_construct.bind(object))
		add_custom_control(button)


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if object is CogniteAssemble:
		if name == "nodes":
			return true


func cognite_assembly_construct(cogNode: CogniteNode):
	for child in cogNode.get_children():
		if child.name == "ROOT":
			child.queue_free()
	
	var root_node: Node
	if cogNode.cognite_assemble_root:
		var gdscript: GDScript = CogniteData.assembly(cogNode.cognite_assemble_root, 0)
		root_node = gdscript.new()
		
		cogNode.add_child(root_node)
		root_node.owner = EditorInterface.get_edited_scene_root()
		root_node.set_name("ROOT")
	
	else:
		return
	
	for modus in cogNode.cognite_assemble_root.nodes.values():
		if modus.type != CogniteAssemble.MODUS:
			continue
		
		var _name: String = cogNode.cognite_assemble_root.source.states[modus.state -1]
		var result: Array = generate_node_modus(modus, CogniteData.except_letters(_name).to_upper(), root_node)
		if result.is_empty():
			continue
		
		var node: Node = result[0]
		var assemble: CogniteAssemble = result[1]
		
		for _modus in assemble.nodes.values():
			if _modus.type != CogniteAssemble.MODUS:
				continue
			
			var __name: String = assemble.source.states[_modus.state -1]
			var _result: Array = generate_node_modus(_modus, __name, node)
	
	EditorInterface.save_all_scenes()


func generate_node_modus(modus: Dictionary, name: String, parent: Node):
	if not modus.has("assembly"):
		return []
	
	var assembly: CogniteAssemble = load(modus.assembly)
	if not assembly:
		return []
	
	var gdscript: GDScript = CogniteData.assembly(assembly, modus.state)
	if not gdscript:
		return []
	
	var node: Node = gdscript.new()
	
	parent.add_child(node)
	node.owner = EditorInterface.get_edited_scene_root()
	node.set_name(CogniteData.except_letters(name).to_upper())
	return [node, assembly]


func is_resource_deleted(file_name: String):
	last_resource.resource_name = file_name
	bottom_panel.hide_editor()


