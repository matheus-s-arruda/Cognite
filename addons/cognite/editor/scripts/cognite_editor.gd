@tool
extends Control


const CREATE_NODEGRAPH = preload("res://addons/cognite/editor/create_nodegraph.tscn")
const GRAPH_NODES := {
	CogniteData.Types.MODUS: preload("res://addons/cognite/editor/graphnodes/modus.tscn"),
	CogniteData.Types.EVENTS: preload("res://addons/cognite/editor/graphnodes/events.tscn"),
	CogniteData.Types.CONDITION: preload("res://addons/cognite/editor/graphnodes/condition.tscn"),
	CogniteData.Types.CHANGE_STATE: preload("res://addons/cognite/editor/graphnodes/change_states.tscn"),
	CogniteData.Types.RANGE: preload("res://addons/cognite/editor/graphnodes/range.tscn"),
}

var nodes: Dictionary
var assemble: CogniteAssemble
var create_nodegraph: OptionButton = CREATE_NODEGRAPH.instantiate()

@onready var graph_edit: GraphEdit = $PanelContainer/GraphEdit
@onready var label: Label = $PanelContainer/Label


func _ready():
	graph_edit.add_valid_connection_type(1, 0)
	graph_edit.get_menu_hbox().add_child(create_nodegraph)
	create_nodegraph.item_selected.connect(_on_create_nodegraph_item_selected)


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


func _on_create_nodegraph_item_selected(index: int):
	create_nodegraph.selected = 0
	create_node(index - 1, 0)


func _on_graph_edit_connection_request(from_node, from_port, to_node, to_port):
	var front_id = graph_edit.get_node(NodePath(from_node)).id
	var to_node_id = graph_edit.get_node(NodePath(to_node)).id
	
	graph_edit.connect_node(from_node, from_port, to_node, to_port)
	assemble.nodes[front_id].right_connections[to_node_id] = Vector2i(from_port, to_port)
	assemble.actualize()


func _on_graph_edit_disconnection_request(from_node, from_port, to_node, to_port):
	var front_id = graph_edit.get_node(NodePath(from_node)).id
	var to_node_id = graph_edit.get_node(NodePath(to_node)).id
	
	graph_edit.disconnect_node(from_node, from_port, to_node, to_port)
	assemble.nodes[front_id].right_connections.erase(to_node_id)
	assemble.actualize()
