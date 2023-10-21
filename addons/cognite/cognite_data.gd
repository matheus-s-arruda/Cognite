@tool
class_name CogniteData extends RefCounted

enum Types {MODUS, EVENTS, CHANGE_STATE, CONDITION, RANGE}

const ROUTINE_SEARCH_FAIL := true
const CODE_PROPERTY_NAMES := {"state": [], "signal": [], "conditions": [], "ranges": []}
const CODE_HEAD := "extends Node\n"
const CODE_EXPORT := "
## Change this property to something other than STATELESS to make your system work. STATELESS is a disable condition.
@export var current_state: State

@onready var initial_state = current_state

## Node that will be observed, this node must contain the methods and properties that CogniteBehavior will access
@export var Main_node: Node

@export_group(\"States Behavior\")\n"
const CODE_PARENT_CHANGED_SIGNAL := "	get_parent().state_changed.connect(_parent_state_changed)\n"
const CODE_READY := "func _ready():\n"
const CODE_PROCESS := "

func _process(delta):
	if current_states_behavior:
		current_states_behavior.process(delta)
"
const CODE_PHYSICS_PROCESS := "

func _physics_process(delta):
	if current_states_behavior:
		current_states_behavior.physics_process(delta)
"
const CODE_ROUTINE_DATA := {
	"modus": "", "event": "", "body": {},
}
const CODE_CHANGE_STATE := "\n
func change_state(new_state):
	if new_state == current_state:
		return
	
	if not is_active:
		current_state = State.STATELESS
	
	current_states_behavior = null
	if states_behavior[new_state]:
		current_states_behavior = states_behavior[new_state]
		current_states_behavior.start()
	
	current_state = new_state
	state_changed.emit(current_state)
\n"
const CODE_PARENT_CHANGED_RECEIVER := "\n
func _parent_state_changed(state: int):
	var flag = is_active
	is_active = state == relative_parent_state
	
	if not flag and is_active:
		change_state(initial_state)
"
const TEXT_ERROR_FAIL_CONDITION := "There are Condition nodes in the graph but there are no Condition variables in \"CogniteSource\".
Add some variable to the \"conditions\" list in your CogniteSource."

const TEXT_ERROR_FAIL_RANGE := "There are range nodes in the graph, but there are no range variables in \"CogniteSource\".
Add some variable to the \"ranges\" list in your CogniteSource."

const TEXT_ERROR_FAIL_EVENT := "There are event nodes in the graph, but there are no trigger variables in \"CogniteSource\".
Add some variable to the \"triggers\" list in your CogniteSource."


static func assembly(cognite_assemble: CogniteAssemble, relative_parent_state: int):
	var code_names := CODE_PROPERTY_NAMES.duplicate(true)
	var code := CODE_HEAD
	
	if cognite_assemble.source.states.is_empty():
		return
	
	for state in cognite_assemble.source.states:
		code_names.state.append(except_letters(state).to_upper())
	
	for trigger in cognite_assemble.source.triggers:
		code_names.signal.append(except_letters(trigger))
	
	for condition in cognite_assemble.source.conditions:
		code_names.conditions.append(except_letters(condition))
	
	for range in cognite_assemble.source.ranges:
		code_names.ranges.append(except_letters(range))
	
	code += get_states(code_names)
	code += get_signals(code_names)
	code += CODE_EXPORT
	
	var state_behavior: String = "\nvar states_behavior := {"
	for state in code_names.state:
		code += "@export var " + state.to_lower() + "_behavior: CogniteBehavior\n"
		state_behavior += "\n	State." + state +": " + state.to_lower() + "_behavior,"
	
	code += "\nvar current_states_behavior: CogniteBehavior\n"
	code += state_behavior + "\n}\n"
	code += get_ranges(code_names)
	code += get_conditions(code_names)
	code += "var is_active := true\n\n"
	
	if relative_parent_state != 0:
		code += "var relative_parent_state: int\n"
	
	var routines: Array
	for node in cognite_assemble.nodes.values():
		if node.type == Types.MODUS:
			get_routines(node, routines, code_names, cognite_assemble)
	
	var events: Dictionary
	mont_signals(routines, events)
	
	code += CODE_READY
	var nothing_in_ready = true
	
	if relative_parent_state != 0:
		code += CODE_PARENT_CHANGED_SIGNAL
		code += "\n	relative_parent_state = " + str(relative_parent_state) + "\n\n"
		nothing_in_ready = false
	
	for event in events:
		code += "	" + event + ".connect(_on_" + event + ")\n"
		nothing_in_ready = false
	
	if nothing_in_ready:
		code += '	pass\n'
	
	code += CODE_PROCESS
	var nothing_in_process = true
	
	for routine in routines:
		if not routine.event.is_empty():
			continue
		
		nothing_in_process = false
		code += "\n	if current_state == State." + routine.modus + ":\n"
		code += build_routine(routine.body, 2)
	
	if nothing_in_process:
		code += "	pass\n"
	
	code += CODE_PHYSICS_PROCESS
	
	code += CODE_CHANGE_STATE
	if relative_parent_state != 0:
		code += CODE_PARENT_CHANGED_RECEIVER
	
	code += "\n\n"
	for event in events:
		code += "func _on_" + event + "():"
		for body in events[event]:
			code += body
		
		code += "\n\n"
	
	var gdscript = GDScript.new()
	gdscript.source_code = code
	gdscript.reload()
	return gdscript

static func get_states(code_names: Dictionary):
	var code := "\nenum State {STATELESS"
	for state in code_names.state:
		code += ", " + state
	code += "}\n"
	return code

static func get_signals(code_names: Dictionary):
	var code := "\n"
	code += "signal state_changed(state)\n"
	for sinal in code_names.signal:
		code += "signal " + sinal + "\n"
	code += "\n"
	return code

static func get_conditions(code_names: Dictionary):
	var code := "\n"
	for condition in code_names.conditions:
		code += "var " + condition + ": bool\n"
	return code

static func get_ranges(code_names: Dictionary):
	var code := "\n"
	for range in code_names.ranges:
		code += "var " + range + ": float\n"
	return code

static func get_routines(node_modus: Dictionary, routines: Array, code_names: Dictionary, cognite_assemble: CogniteAssemble):
	for node_id in node_modus.right_connections:
		var routine := CODE_ROUTINE_DATA.duplicate(true)
		
		if not cognite_assemble.nodes.has(node_id):
			continue
		
		match cognite_assemble.nodes[node_id].type:
			Types.CHANGE_STATE:
				routine.modus = code_names.state[node_modus.state -1]
				routine.body["body"] = change_state_routine(code_names, cognite_assemble.nodes[node_id].change_state -1)
			
			Types.CONDITION:
				if code_names.conditions.is_empty():
					Cognite.emit_alert(TEXT_ERROR_FAIL_CONDITION)
				
				var new_condition = code_names.conditions[cognite_assemble.nodes[node_id].condition -1]
				var _condition_routine: Dictionary
				var result = condition_routine(cognite_assemble.nodes[node_id], _condition_routine, code_names, cognite_assemble)
				if result:
					if result is bool:
						continue
					
					if routine.event.is_empty():
						routine.event = result
					else:
						continue
				
				routine.modus = code_names.state[node_modus.state -1]
				routine.body = {new_condition: _condition_routine}
			
			Types.RANGE:
				if code_names.ranges.is_empty():
					Cognite.emit_alert(TEXT_ERROR_FAIL_RANGE)
				
				var new_range = code_names.ranges[cognite_assemble.nodes[node_id].range -1]
				var _range_routine: Dictionary
				var result = range_routine(cognite_assemble.nodes[node_id], _range_routine, code_names, cognite_assemble)
				if result:
					if result is bool:
						continue
					
					if routine.event.is_empty():
						routine.event = result
					else:
						continue
				routine.modus = code_names.state[node_modus.state -1]
				routine.body = {new_range: _range_routine}
			
			Types.EVENTS:
				if not routine.event.is_empty():
					continue
				
				if code_names.signal.is_empty():
					Cognite.emit_alert(TEXT_ERROR_FAIL_EVENT)
				
				var new_event = code_names.signal[cognite_assemble.nodes[node_id].trigger -1]
				var event_routine: Dictionary
				
				if event_routine(cognite_assemble.nodes[node_id], event_routine, code_names, cognite_assemble):
					continue
				
				routine.event = new_event
				routine.body = event_routine
				routine.modus = code_names.state[node_modus.state -1]
		
		routines.append(routine)

static func event_routine(event: Dictionary, _event_routine: Dictionary, code_names: Dictionary, cognite_assemble: CogniteAssemble):
	var sucess: bool
	for _node_id in event.right_connections:
		if not cognite_assemble.nodes.has(_node_id):
			continue
		
		match cognite_assemble.nodes[_node_id].type:
			Types.CHANGE_STATE:
				_event_routine["body"] = change_state_routine(code_names, cognite_assemble.nodes[_node_id].change_state -1)
				sucess = true
			
			Types.CONDITION:
				if code_names.conditions.is_empty():
					Cognite.emit_alert(TEXT_ERROR_FAIL_CONDITION)
				
				var new_condition = code_names.conditions[cognite_assemble.nodes[_node_id].condition -1]
				var _condition_routine: Dictionary
				var result = condition_routine(cognite_assemble.nodes[_node_id], _condition_routine, code_names, cognite_assemble)
				if result:
					return true
				
				_event_routine[new_condition] = _condition_routine
				sucess = true
			
			Types.RANGE:
				if code_names.ranges.is_empty():
					Cognite.emit_alert(TEXT_ERROR_FAIL_RANGE)
				
				var new_range = code_names.ranges[cognite_assemble.nodes[_node_id].range -1]
				var _range_routine: Dictionary
				var result =  range_routine(cognite_assemble.nodes[_node_id], _range_routine, code_names, cognite_assemble)
				if result:
					return true
				
				_event_routine[new_range] = _range_routine
				sucess = true
			
			Types.EVENTS:
				return true
	if not sucess:
		return true

static func range_routine(node: Dictionary, routine: Dictionary, code_names: Dictionary, cognite_assemble: CogniteAssemble):
	var sucess: bool
	for node_id in node.right_connections:
		if not cognite_assemble.nodes.has(node_id):
			continue
		
		var key = "smaller" if node.right_connections[node_id].x == 1 else "bigger"
		if not routine.has(key) or (routine.has(key) and routine[key].is_empty()):
			routine[key] = {"value": node[key]}
		
		var new_routine: Dictionary
		
		match cognite_assemble.nodes[node_id].type:
			Types.CHANGE_STATE:
				routine[key]["body"] = change_state_routine(code_names, cognite_assemble.nodes[node_id].change_state -1)
				sucess = true
				
			Types.CONDITION:
				if code_names.conditions.is_empty():
					Cognite.emit_alert(TEXT_ERROR_FAIL_CONDITION)
				
				var new_condition = code_names.conditions[cognite_assemble.nodes[node_id].condition -1]
				var result = condition_routine(cognite_assemble.nodes[node_id], new_routine, code_names, cognite_assemble)
				if result:
					return result
				routine[key][new_condition] = new_routine
				sucess = true
			
			Types.RANGE:
				if code_names.ranges.is_empty():
					Cognite.emit_alert(TEXT_ERROR_FAIL_RANGE)
				
				var new_range = code_names.ranges[cognite_assemble.nodes[node_id].range -1]
				var result = range_routine(cognite_assemble.nodes[node_id], new_routine, code_names, cognite_assemble)
				if result:
					return result
				routine[key][new_range] = new_routine
				sucess = true
			
			Types.EVENTS:
				if code_names.signal.is_empty():
					Cognite.emit_alert(TEXT_ERROR_FAIL_EVENT)
				
				var new_event = code_names.signal[cognite_assemble.nodes[node_id].trigger -1]
				if event_routine(cognite_assemble.nodes[node_id], new_routine, code_names, cognite_assemble):
					continue
				routine[key][new_event] = new_routine
				return code_names.signal[cognite_assemble.nodes[node_id].trigger -1]
	
	if not sucess:
		return true

static func condition_routine(node: Dictionary, routine: Dictionary, code_names: Dictionary, cognite_assemble: CogniteAssemble):
	var sucess: bool
	for node_id in node.right_connections:
		if not cognite_assemble.nodes.has(node_id):
			continue
		
		var key = "else" if node.right_connections[node_id].x == 1 else "ifs"
		var new_routine: Dictionary
		routine[key] = {}
		
		match cognite_assemble.nodes[node_id].type:
			Types.CHANGE_STATE:
				routine[key]["body"] = change_state_routine(code_names, cognite_assemble.nodes[node_id].change_state -1)
				sucess = true
			
			Types.CONDITION:
				if code_names.conditions.is_empty():
					Cognite.emit_alert(TEXT_ERROR_FAIL_CONDITION)
				
				var new_condition = code_names.conditions[cognite_assemble.nodes[node_id].condition -1]
				routine[key][new_condition] = new_routine
				
				var result = condition_routine(cognite_assemble.nodes[node_id], new_routine, code_names, cognite_assemble)
				if result:
					return result
				sucess = true
			
			Types.RANGE:
				if code_names.ranges.is_empty():
					Cognite.emit_alert(TEXT_ERROR_FAIL_RANGE)
				
				var new_range = code_names.ranges[cognite_assemble.nodes[node_id].range -1]
				routine[key][new_range] = new_routine
				
				var result = range_routine(cognite_assemble.nodes[node_id], new_routine, code_names, cognite_assemble)
				if result:
					return result
				sucess = true
			
			Types.EVENTS:
				if code_names.signal.is_empty():
					Cognite.emit_alert(TEXT_ERROR_FAIL_EVENT)
				
				var new_event = code_names.signal[cognite_assemble.nodes[node_id].trigger -1]
				if event_routine(cognite_assemble.nodes[node_id], new_routine, code_names, cognite_assemble):
					continue
				
				routine[key] = new_routine
				return code_names.signal[cognite_assemble.nodes[node_id].trigger -1]
	if not sucess:
		return true

static func change_state_routine(code_names: Dictionary, state_id: int):
	var state: String = code_names.state[state_id]
	return "change_state(State." + state + ")\n"

static func build_routine(body: Dictionary, identation: int):
	var code: String
	
	if body.has("body"):
		code += "	".repeat(identation) + body.body
	
		if body.body is String:
			return code
	
	for member in body:
		if member == "value":
			continue
		
		if body[member].has("ifs"):
			code += "	".repeat(identation) + "if "+ member + ":\n"
			code += build_routine(body[member].ifs, identation + 1)
			
			if body[member].has("else"):
				code += "	".repeat(identation) + "else:\n"
				code += build_routine(body[member].else, identation + 1)
		
		elif body[member].has("else"):
			code += "	".repeat(identation) + "if not "+ member + ":\n"
			code += build_routine(body[member].else, identation + 1)
		
		if body[member].has("bigger"):
			code += "	".repeat(identation) + "if "+ member+ " > " + str(body[member].bigger.value) + ":\n"
			code += build_routine(body[member].bigger, identation + 1)
		
		if body[member].has("smaller"):
			code += "	".repeat(identation) + "if "+ member+ " < " + str(body[member].smaller.value) + ":\n"
			code += build_routine(body[member].smaller, identation + 1)
	
	return code

static func mont_signals(routines: Array, events: Dictionary):
	for routine in routines:
		if routine.event.is_empty():
			continue
		
		var _code: String = "\n	if current_state == State." + routine.modus + ":\n"
		_code += build_routine(routine.body, 2)
		
		if events.has(routine.event):
			events[routine.event].append(_code)
		else:
			events[routine.event] = [_code]

static func except_letters(input_string: String) -> String:
	var regex := RegEx.new()
	regex.compile("[^A-Za-z_]") 
	input_string = regex.sub(input_string, "")
	input_string = input_string.replace(" ", "_")
	return input_string
