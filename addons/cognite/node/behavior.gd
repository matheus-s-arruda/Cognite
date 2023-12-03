@tool
class_name CogniteBehavior extends Node
## DO NOT MODIFY THIS CODE.[br][br]
## Instead, create a script and extend it from [code]CogniteBehavior[/code].
##
## Use this class as a child node of CogniteNode to add behaviors according to [code]CogniteNode.curren_state[/code].

## State relative to CogniteSource.state on its parent CogniteNode.
var state: int

## CogniteNode parent.
@onready var cognite_node: CogniteNode = $".."


func _init():
	await ready
	if not cognite_node is CogniteNode: return
	cognite_node.state_changed.connect(update)
	
	set_process(false)
	set_physics_process(false)


func _get_property_list():
	var property_list: Array[Dictionary]
	
	if cognite_node and cognite_node.cognite_assemble_root and cognite_node.cognite_assemble_root.source:
		var string_array = PackedStringArray(cognite_node.cognite_assemble_root.source.states)
		var hint_string = ",".join(string_array)
		
		property_list.append(
			{
				"name": "state",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": hint_string
			}
		)
	return property_list

## Activates the node if its state is the same as the current CogniteNode.
func update(new_state: int):
	if new_state == state: start()
	set_process(new_state ==  state)
	set_physics_process(new_state ==  state)

## This function will be called as soon as the state is active.[br][br]
## override this function in your legacy gdscript code.
func start():
	pass

## Will be active when the state is active.[br][br]
## override this function in your legacy gdscript code.
func _physics_process(delta):
	pass

## Will be active when the state is active.[br][br]
## override this function in your legacy gdscript code.
func _process(delta):
	pass
