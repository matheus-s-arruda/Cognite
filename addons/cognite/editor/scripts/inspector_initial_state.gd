@tool
extends HBoxContainer


var cognite_node: CogniteNode
@onready var opitions = $opitions


func _input(event: InputEvent):
	if cognite_node.cognite_assemble_root:
		opitions.clear()
		
		for item in cognite_node.cognite_assemble_root.get_states():
				opitions.add_item(item)
		
		opitions.selected = cognite_node.initial_state
