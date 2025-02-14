@tool
extends Control

const GRAPH_NODES := {
	CogniteData.Types.MODUS: preload("res://addons/cognite/editor/graphnodes/modus.tscn"),
	CogniteData.Types.EVENTS: preload("res://addons/cognite/editor/graphnodes/events.tscn"),
	CogniteData.Types.CONDITION: preload("res://addons/cognite/editor/graphnodes/condition.tscn"),
	CogniteData.Types.CHANGE_STATE: preload("res://addons/cognite/editor/graphnodes/change_states.tscn"),
	CogniteData.Types.RANGE: preload("res://addons/cognite/editor/graphnodes/range.tscn"),
	CogniteData.Types.CHANGE_PROPERTY: preload("res://addons/cognite/editor/graphnodes/change_property.tscn"),
}

var nodes: Dictionary
var assemble: CogniteAssemble

@onready var graph_edit: GraphEdit = $PanelContainer/GraphEdit
@onready var label: Label = $PanelContainer/Label

func show_editor(_assemble):
	clear_graph()
	assemble = _assemble
	
	for id in assemble.nodes:
		if id != 1:
			create_node(assemble.nodes[id].type, id)
	
	for id in assemble.nodes:
		for node_id in assemble.nodes[id].right_connections:
			if nodes.has(node_id) and nodes.has(id):
				var port: Vector2i = assemble.nodes[id].right_connections[node_id]
				graph_edit.connect_node(nodes[id].name, port.x, nodes[node_id].name, port.y)
	
	graph_edit.visible = true
	label.visible = false


func hide_editor():
	graph_edit.visible = false
	label.visible = true
	clear_graph()


func clear_graph():
	graph_edit.clear_connections()
	for node_id in nodes:
		if node_id != 1:
			if is_instance_valid(nodes[node_id]):
				nodes[node_id].queue_free()
	nodes.clear()


func create_node(type: int, id: int):
	var new_graph_node: CogniteGraphNode = GRAPH_NODES[type].instantiate()
	var _id: int = new_graph_node.init(assemble, id, type)
	var string: String = str(hash(type))
	string = string.left(6 - string.length())
	
	nodes[_id] = new_graph_node
	new_graph_node.size = Vector2.ZERO
	new_graph_node.graph_editor = self
	new_graph_node.modulate = (Color(string) + Color(0.8, 0.8, 0.8, 1.0)).clamp()
	graph_edit.add_child(new_graph_node)
	if id == 0:
		new_graph_node.position_offset = Vector2(100, 100)
	
	return new_graph_node


func remove_node(id: int):
	var node = nodes[id]
	if not is_instance_valid(node):
		print("ERROR: remove_node::is_instance_valid() : nodes[id]")
		return
	
	for node_id in assemble.nodes[id].right_connections:
		if not nodes.has(node_id):
			continue
		
		var conection_node = nodes[node_id]
		var ports: Vector2i = assemble.nodes[id].right_connections[node_id]
		
		if is_instance_valid(conection_node):
			graph_edit.disconnect_node(node.name, ports.x, conection_node.name, ports.y)
		else:
			print("ERROR: remove_node::is_instance_valid() : conection_node")
	
	for node_id in assemble.nodes:
		if node_id == id:
			continue
		
		var conection_node = nodes[node_id]
		for connection_node_id in assemble.nodes[node_id].right_connections:
			if connection_node_id == id:
				var ports: Vector2i = assemble.nodes[node_id].right_connections[connection_node_id]
				graph_edit.disconnect_node(conection_node.name, ports.x, node.name, ports.y)
	
	assemble.nodes.erase(id)
	nodes.erase(id)
