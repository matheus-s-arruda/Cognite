@tool
class_name CogniteAssemble extends Resource

signal actualized

const PERCEPTION_TEMPLATE := {"name": "", "type": 0, "prop1": 0, "prop2": 0}
const CONTEXT_TEMPLATE := {"name": "", "activated": true, "perception_ids": {}}
const DECISION_TEMPLATE := {"name": "", "activated": true, "base_score": 0, "context_ids": {}}
const ACTION_TEMPLATE := {"activated": true, "decision_id": 0, "deed_list": []}

@export var creation_count := 0
@export var perceptions: Dictionary
@export var contexts: Dictionary
@export var decisions: Dictionary
@export var actions: Dictionary
@export var deeds: Dictionary


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


func create_action(decision_id: int) -> Array:
	var action := ACTION_TEMPLATE.duplicate(true)
	action.decision_id = decision_id
	actions[creation_count] = action
	creation_count += 1
	actualize()
	return [creation_count, action]

func atualize_action(id: int, action: Dictionary):
	action[id] = action
	actualize()

func get_action(id: int) -> Dictionary:
	if actions.has(id): return actions[id]
	return {}


func create_deed() -> int:
	deeds[creation_count] = ""
	creation_count += 1
	actualize()
	return creation_count


func is_cognite_assemble():
	return true

func actualize():
	take_over_path(resource_path)
	ResourceSaver.save(self, resource_path)
	actualized.emit()
