@tool
class_name CogniteAssemble extends Resource

signal actualized


@export var nodes: Dictionary


func get_states() -> Array[String]:
	var array: Array[String]
	
	for id in nodes:
		var node: Dictionary = nodes[id]
		if node.type == 0 and node.has("state"):
			array.append(node.state)
	
	return array


func is_cognite_assemble():
	return true


func actualize():
	actualized.emit()
