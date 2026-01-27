@tool
class_name CogniteNode extends Node


@export var cognite_assemble: CogniteAssemble


var perceptions: Dictionary
var context: Dictionary
var updating: bool

var runtime_context: Dictionary
var runtime_decision: Dictionary
var decisions: Dictionary


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


func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	for crc in runtime_context:
		runtime_context[crc].is_valid()
	
	for dcs in runtime_decision:
		decisions[dcs] = runtime_decision[dcs].get_score()
	
	var keys = decisions.keys()
	keys.sort_custom(sort_decision_score)
	#keys.reverse()
	print(decisions[keys[0]])
	#var decision_best_match := 0
	#var decision_best_match_value := 0
	#for i in decisions.size() -1:
		#if decisions.keys()[i] > decisions.keys()[i + 1]:
			#decision_best_match = decisions.keys()[i]
			#decision_best_match_value
		#else:
			#decision_best_match = decisions.keys()[i + 1]
	
	#print(cognite_assemble.decisions[decision_best_match].name, " : ")


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
