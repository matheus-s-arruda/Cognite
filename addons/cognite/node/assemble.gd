@tool
class_name CogniteAssemble extends Resource

signal actualized

const PERCEPTION_CONTEXT_TEMPLATE := {"bool": false, "min": 0, "max": 1, "text": ""}
const CONTEXT_TEMPLATE := {"name": "", "activated": true, "perception_ids": {}}
const DECISION_TEMPLATE := {"name": "", "activated": true, "base_score": 0, "context_ids": {}}
const ACTION_TEMPLATE := {"activated": true, "decision_id": 0, "deed_list": []}
const DEED_TEMPLATE := {"name": "", "process_mode": 1}

@export var creation_count := 0
@export var perceptions: Dictionary
@export var contexts: Dictionary
@export var decisions: Dictionary
@export var actions: Dictionary
@export var deeds: Dictionary

@export var perception_runtime_value: Dictionary

func create_perception() -> int:
	var p := creation_count
	perceptions[creation_count] = ["", 0]
	creation_count += 1
	actualize()
	return p

func atualize_perception(id: int, _name: String, type: int):
	perceptions[id] = [_name, type]
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


func create_action(decision_id: int) -> Array:
	var action := ACTION_TEMPLATE.duplicate(true)
	var a = [creation_count, action]
	action.decision_id = decision_id
	actions[creation_count] = action
	creation_count += 1
	actualize()
	return a

func atualize_action(id: int, action: Dictionary):
	actions[id] = action
	actualize()

func get_action(id: int) -> Dictionary:
	if actions.has(id): return actions[id]
	return {}


func create_deed() -> Array:
	var deed := DEED_TEMPLATE.duplicate(true)
	var d = [creation_count, deed]
	deeds[creation_count] = deed
	creation_count += 1
	actualize()
	return d

func atualize_deed(id: int, deed: Dictionary):
	deeds[id] = deed
	actualize()

func get_deed(id: int) -> Dictionary:
	if deeds.has(id): return deeds[id]
	return {}

func clear_deeds() -> void:
	var used: Dictionary = {}
	var to_remove: Array = []
	
	for action in actions.values():
		for deed_id in action.deed_list:
			used[deed_id] = true
	
	for deed_id in deeds.keys():
		if not used.has(deed_id):
			to_remove.append(deed_id)
	
	for deed_id in to_remove:
		deeds.erase(deed_id)
	
	for action in actions.values():
		var valid_list: Array = []
		
		for deed_id in action.deed_list:
			if deeds.has(deed_id):
				valid_list.append(deed_id)
		action.deed_list = valid_list


func atualize_perception_runtime_value(perception_name: String, value):
	perception_runtime_value[perception_name] = value
	if Engine.is_editor_hint(): actualize()


func actualize():
	take_over_path(resource_path)
	ResourceSaver.save(self, resource_path)
	actualized.emit()
