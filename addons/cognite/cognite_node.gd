@tool
class_name CogniteNode extends Node

## This value will indicate how many times a machine can be built within another machine
@export var root_depth_level := 3:
	set(value):
		root_depth_level = clamp(value, 0, 99)

@export var cognite_assemble_root: CogniteAssemble

func is_cognite_node():
	pass
