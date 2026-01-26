@tool
class_name CogniteAssemble extends Resource

signal actualized

const PERCEPTION_TEMPLATE := {"name": "", "type": 0, "prop1": 0, "prop2": 0}
const CONTEXT_TEMPLATE := {"name": "", "activated": true, "base_score": 0, "perception_ids": {}}

@export var creation_count := 0
@export var perceptions: Dictionary
@export var contexts: Dictionary


func create_perception() -> Array:
	var p := [creation_count, PERCEPTION_TEMPLATE.duplicate(true)]
	perceptions[creation_count] = PERCEPTION_TEMPLATE.duplicate(true)
	creation_count += 1
	actualize()
	return p

func atualize_perception(id: int, perception: Dictionary):
	perceptions[id] = perception
	actualize()

func get_perception(id: int) -> Dictionary:
	if perceptions.has(id): return perceptions[id]
	return {}


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
