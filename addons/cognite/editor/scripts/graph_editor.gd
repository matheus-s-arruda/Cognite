@tool
extends GraphEdit

const CREATE_NODEGRAPH = preload("res://addons/cognite/editor/create_nodegraph.tscn")

var create_opitions: OptionButton = CREATE_NODEGRAPH.instantiate()

@onready var editor: VBoxContainer = $"../.."


func _ready():
	add_valid_connection_type(1, 0)
	get_menu_hbox().add_child(create_opitions)
	create_opitions.item_selected.connect(_on_create_nodegraph_item_selected)


func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		create_opitions.show_popup()
		var popup: PopupMenu = create_opitions.get_popup()
		popup.set_position(create_opitions.get_global_mouse_position())


func _on_create_nodegraph_item_selected(index: int):
	create_opitions.selected = 0
	var new_graph_node: CogniteGraphNode = editor.create_node(index - 1, 0)
	new_graph_node.position_offset = (scroll_offset + get_local_mouse_position()) / zoom


func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var front_id = get_node(NodePath(from_node)).id
	var to_node_id = get_node(NodePath(to_node)).id
	
	connect_node(from_node, from_port, to_node, to_port)
	
	if editor.assemble != null:
		editor.assemble.nodes[front_id].right_connections[to_node_id] = Vector2i(from_port, to_port)
		editor.assemble.actualize()


func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var front_id = get_node(NodePath(from_node)).id
	var to_node_id = get_node(NodePath(to_node)).id
	
	disconnect_node(from_node, from_port, to_node, to_port)
	
	if editor.assemble != null:
		editor.assemble.nodes[front_id].right_connections.erase(to_node_id)
		editor.assemble.actualize()
