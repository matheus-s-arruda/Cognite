@tool
class_name CogniteNode extends Node


@export var cognite_assemble: CogniteAssemble


var perceptions: Dictionary
var context: Dictionary
var updating: bool

var runtime_context: Dictionary
var runtime_decision: Dictionary
var runtime_action: Dictionary
var decisions: Dictionary

var current_decision: Dictionary
var best_score_decision: int
var highest_score_decision: int


func _enter_tree() -> void:
	if Engine.is_editor_hint(): return
	
	for id in cognite_assemble.perceptions:
		var per: Dictionary = cognite_assemble.perceptions[id]
		perceptions[per.name] = false if per.type == 0 else 0.0
	
	for context_id in cognite_assemble.contexts:
		runtime_context[context_id] = CogniteRuntimeContext.new(cognite_assemble.contexts[context_id], cognite_assemble, self)
	
	for decision_id in cognite_assemble.decisions:
		decisions[decision_id] = 0
		runtime_decision[decision_id] = CogniteRuntimeDecision.new(cognite_assemble.decisions[decision_id], self)
	
	for action_id in cognite_assemble.actions:
		runtime_action[action_id] = CogniteRuntimeAction.new(cognite_assemble.actions[action_id], self)


func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	for crc in runtime_context:
		runtime_context[crc].is_valid()
	
	for dcs in runtime_decision:
		decisions[dcs] = runtime_decision[dcs].get_score()
	
	var keys = decisions.keys()
	keys.sort_custom(sort_decision_score)
	best_score_decision = keys[0]
	highest_score_decision = decisions[keys[0]]
	
	current_decision = cognite_assemble.decisions[best_score_decision]


func is_cognite_node():
	return true

func _get_property_list():
	var props := []
	
	if not cognite_assemble and cognite_assemble.perceptions.is_empty():
		return props
	
	for id in cognite_assemble.perceptions:
		var per: Dictionary = cognite_assemble.perceptions[id]
		props.append({"name": per.name, "type": TYPE_BOOL if per.type == 0 else TYPE_FLOAT})
	
	return props

func _get(property: StringName):
	if not perceptions.has(property): return
	return perceptions[property]

func _set(property, value):
	if not perceptions.has(property): return false
	var last_value = perceptions[property]
	
	if (last_value is bool and value is bool) or (last_value is float and (value is float or value is int)):
		perceptions[property] = value
		return true

func sort_decision_score(a, b):
	return decisions[a] > decisions[b]
