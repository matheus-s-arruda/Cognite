@tool
class_name CogniteAssemble extends Resource

signal actualized

static var current_assemble: CogniteAssemble


@export var nodes: Dictionary

@export var cognite_paths: CognitePerpectionResource


func is_cognite_assemble():
	return true


func actualize():
	actualized.emit()
