@tool
class_name CogniteAssemble extends Resource

signal actualized

const CONTEXT_TEMPLATE := {"name": "", "activated": true, "min_shot": 0, "perception_ids": {}}
const DECISION_TEMPLATE := {"name": "", "priority": 0, "activated": true, "context_ids": []}

@export var creation_count := 0

@export var perceptions: Dictionary
@export var contexts: Dictionary
@export var decisions: Dictionary


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


func create_decision() -> Array:
	var d = [creation_count, DECISION_TEMPLATE.duplicate(true)]
	decisions[creation_count] = DECISION_TEMPLATE.duplicate(true)
	creation_count += 1
	actualize()
	return d

func atualize_decision(id: int, decision: Dictionary):
	decisions[id] = decision
	actualize()

func get_decision(id: int) -> Dictionary:
	if decisions.has(id): return decisions[id]
	return {}


func is_cognite_assemble():
	return true

func actualize():
	take_over_path(resource_path)
	ResourceSaver.save(self, resource_path)
	actualized.emit()
