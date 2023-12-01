@tool
class_name CogniteNode extends Node


@export var cognite_assemble_root: CogniteAssemble:
	set(value):
		if cognite_assemble_root != value:
			value.actualized.connect(actualized)
		
		cognite_assemble_root = value

var root_node: Node
var is_active := true


func actualized():
	var propertie_names: Dictionary = CogniteData.get_propertie_names(cognite_assemble_root)
	var routines: Array = CogniteData.create_routines(cognite_assemble_root, propertie_names)
	


func is_cognite_node(): pass
