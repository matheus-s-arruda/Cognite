@tool
class_name CogniteAssemble extends Resource

signal actualized


@export var nodes: Dictionary
@export var source: CogniteSource


func is_cognite_assemble():
	return true


func actualize():
	actualized.emit()
