@tool
class_name CogniteDock extends MarginContainer


const GRAPH_NODES := {
	CogniteGraphNode.Types.PERCEPTION: preload("uid://7tjt5gy3dqh7"),
	CogniteGraphNode.Types.CONTEXT: preload("uid://ctl6hgf0lia2t"),
	CogniteGraphNode.Types.DECISION: preload("uid://baqewkrr2k33n"),
	CogniteGraphNode.Types.ACTION: preload("uid://b2e3ttuqiy7v8")
}


@onready var graph_edit: GraphEdit = $GraphEdit
@onready var label: Label = $Label

var nodes: Dictionary

func atualize(node: Node):
	if node is CogniteNode:
		CogniteAssemble.current_assemble = node.cognite_assemble
		
		if CogniteAssemble.current_assemble:
			show_containers(CogniteAssemble.current_assemble)
		else: hide_containers()
	else: hide_containers()


func show_containers(assemble: CogniteAssemble):
	clear_graph()
	graph_edit.show()
	label.hide()
	
	for id in assemble.nodes:
		if id != 1:
			create_node(assemble.nodes[id].type, id)
	
	for id in assemble.nodes:
		for node_id in assemble.nodes[id].right_connections:
			if nodes.has(node_id) and nodes.has(id):
				var port: Vector2i = assemble.nodes[id].right_connections[node_id]
				graph_edit.connect_node(nodes[id].name, port.x, nodes[node_id].name, port.y)


func hide_containers():
	clear_graph()
	graph_edit.hide()
	label.show()


func clear_graph():
	graph_edit.clear_connections()
	for node_id in nodes:
		if node_id != 1:
			if is_instance_valid(nodes[node_id]):
				nodes[node_id].queue_free()
	nodes.clear()


func create_node(type: int, id: int):
	var new_graph_node: CogniteGraphNode = GRAPH_NODES[type].instantiate()
	var _id: int = new_graph_node.init(CogniteAssemble.current_assemble, id, type)
	var string: String = str(hash(type))
	string = string.left(6 - string.length())
	
	nodes[_id] = new_graph_node
	new_graph_node.size = Vector2.ZERO
	new_graph_node.graph_editor = self
	graph_edit.add_child(new_graph_node)
	if id == 0:
		new_graph_node.position_offset = Vector2(100, 100)
	
	return new_graph_node


func remove_node(id: int):
	var node = nodes[id]
	if not is_instance_valid(node):
		print("ERROR: remove_node::is_instance_valid() : nodes[id]")
		return
	
	for node_id in CogniteAssemble.current_assemble.nodes[id].right_connections:
		if not nodes.has(node_id):
			continue
		
		var conection_node = nodes[node_id]
		var ports: Vector2i = CogniteAssemble.current_assemble.nodes[id].right_connections[node_id]
		
		if is_instance_valid(conection_node):
			graph_edit.disconnect_node(node.name, ports.x, conection_node.name, ports.y)
		else:
			print("ERROR: remove_node::is_instance_valid() : conection_node")
	
	for node_id in CogniteAssemble.current_assemble.nodes:
		if node_id == id:
			continue
		
		var conection_node = nodes[node_id]
		for connection_node_id in CogniteAssemble.current_assemble.nodes[node_id].right_connections:
			if connection_node_id == id:
				var ports: Vector2i = CogniteAssemble.current_assemble.nodes[node_id].right_connections[connection_node_id]
				graph_edit.disconnect_node(conection_node.name, ports.x, node.name, ports.y)
	
	CogniteAssemble.current_assemble.nodes.erase(id)
	nodes.erase(id)
