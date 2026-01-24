@tool
class_name CogniteAssemble extends Resource

signal actualized

const CONTEXT_TEMPLATE := {"name": "", "activated": true, "priority": 0, "min_shot": 0, "perception_ids": {}}

@export var creation_count := 0

@export var perceptions: Dictionary
@export var contexts: Dictionary


func create_perception() -> Array:
	var p := [creation_count, ["", TYPE_INT]]
	perceptions[creation_count] = ["", TYPE_INT]
	creation_count += 1
	actualize()
	return p


func atualize_perception(id: int, perception: Array):
	perceptions[id] = perception
	actualize()


func get_perception(id: int) -> Array:
	if perceptions.has(id): return perceptions[id]
	return []


func create_context() -> Array:
	var c := [creation_count, CONTEXT_TEMPLATE.duplicate(true)]
	contexts[creation_count] = CONTEXT_TEMPLATE.duplicate(true)
	creation_count += 1
	actualize()
	return c


func atualize_context(id: int, context: Dictionary):
	contexts[id] = context
	actualize()


func get_context(id: int) -> Dictionary:
	if contexts.has(id): return contexts[id]
	return {}


func is_cognite_assemble():
	return true


func actualize():
	take_over_path(resource_path)
	ResourceSaver.save(self, resource_path)
	actualized.emit()
