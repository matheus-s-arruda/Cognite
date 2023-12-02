@tool
class_name CogniteData extends RefCounted

enum Types {MODUS, EVENTS, CHANGE_STATE, CONDITION, RANGE}

const ROUTINE_SEARCH_FAIL := true
const CODE_PROPERTY_NAMES := {"state": [], "signal": [], "conditions": [], "ranges": []}
const CODE_ROUTINE_DATA := {"modus": "", "event": "", "body": {}}

const TEXT_ERROR_FAIL_CONDITION := "There are Condition nodes in the graph but there are no Condition variables in \"CogniteSource\".
Add some variable to the \"conditions\" list in your CogniteSource."

const TEXT_ERROR_FAIL_RANGE := "There are range nodes in the graph, but there are no range variables in \"CogniteSource\".
Add some variable to the \"ranges\" list in your CogniteSource."

const TEXT_ERROR_FAIL_EVENT := "There are event nodes in the graph, but there are no trigger variables in \"CogniteSource\".
Add some variable to the \"triggers\" list in your CogniteSource."


class RoutineAsembly:
	var modus: int
	var assemble: Callable
	var _calls: Array[Callable]

class RoutineAsemblyProcess extends RoutineAsembly:
	func process(state: int):
		if modus == state and assemble:
			assemble.call()

class RoutineAsemblyEvent extends RoutineAsembly:
	var cognite_node: CogniteNode
	var event: Signal
	
	func build():
		event.connect(get_modus)
	
	func get_modus():
		if cognite_node.current_state == modus and assemble:
			assemble.call()


static func get_propertie_names(cognite_assemble: CogniteAssemble) -> Dictionary:
	var propertie_names := CODE_PROPERTY_NAMES.duplicate(true)
	if cognite_assemble.source.states.is_empty(): return {}
	
	for state in cognite_assemble.source.states:
		propertie_names.state.append(except_letters(state).to_upper())
	for trigger in cognite_assemble.source.triggers:
		propertie_names.signal.append(except_letters(trigger))
	for condition in cognite_assemble.source.conditions:
		propertie_names.conditions.append(except_letters(condition))
	for range in cognite_assemble.source.ranges:
		propertie_names.ranges.append(except_letters(range))
	
	return propertie_names

static func create_routines(cognite_assemble: CogniteAssemble, propertie_names: Dictionary):
	var routines: Array
	for node in cognite_assemble.nodes.values():
		if node.type == Types.MODUS:
			get_routines(node, routines, propertie_names, cognite_assemble)
	return routines

static func get_routines(node_modus: Dictionary, routines: Array, code_names: Dictionary, cognite_assemble: CogniteAssemble):
	for node_id in node_modus.right_connections:
		var routine := CODE_ROUTINE_DATA.duplicate(true)
		
		if not cognite_assemble.nodes.has(node_id):
			continue
		
		match cognite_assemble.nodes[node_id].type:
			Types.CHANGE_STATE:
				routine.modus = code_names.state[node_modus.state -1]
				routine.body["body"] = code_names.state[cognite_assemble.nodes[node_id].change_state -1]
			
			Types.CONDITION:
				if code_names.conditions.is_empty():
					pass # Cognite.emit_alert(TEXT_ERROR_FAIL_CONDITION)
				
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
					pass # Cognite.emit_alert(TEXT_ERROR_FAIL_RANGE)
				
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
					pass # Cognite.emit_alert(TEXT_ERROR_FAIL_EVENT)
				
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
				_event_routine["body"] = code_names.state[cognite_assemble.nodes[_node_id].change_state -1]
				sucess = true
			
			Types.CONDITION:
				if code_names.conditions.is_empty():
					pass # Cognite.emit_alert(TEXT_ERROR_FAIL_CONDITION)
				
				var new_condition = code_names.conditions[cognite_assemble.nodes[_node_id].condition -1]
				var _condition_routine: Dictionary
				var result = condition_routine(cognite_assemble.nodes[_node_id], _condition_routine, code_names, cognite_assemble)
				if result:
					return true
				
				_event_routine[new_condition] = _condition_routine
				sucess = true
			
			Types.RANGE:
				if code_names.ranges.is_empty():
					pass # Cognite.emit_alert(TEXT_ERROR_FAIL_RANGE)
				
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
				routine[key]["body"] = code_names.state[cognite_assemble.nodes[node_id].change_state -1]
				sucess = true
				
			Types.CONDITION:
				if code_names.conditions.is_empty():
					pass # Cognite.emit_alert(TEXT_ERROR_FAIL_CONDITION)
				
				var new_condition = code_names.conditions[cognite_assemble.nodes[node_id].condition -1]
				var result = condition_routine(cognite_assemble.nodes[node_id], new_routine, code_names, cognite_assemble)
				if result:
					return result
				routine[key][new_condition] = new_routine
				sucess = true
			
			Types.RANGE:
				if code_names.ranges.is_empty():
					pass # Cognite.emit_alert(TEXT_ERROR_FAIL_RANGE)
				
				var new_range = code_names.ranges[cognite_assemble.nodes[node_id].range -1]
				var result = range_routine(cognite_assemble.nodes[node_id], new_routine, code_names, cognite_assemble)
				if result:
					return result
				routine[key][new_range] = new_routine
				sucess = true
			
			Types.EVENTS:
				if code_names.signal.is_empty():
					pass # Cognite.emit_alert(TEXT_ERROR_FAIL_EVENT)
				
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
				routine[key]["body"] = code_names.state[cognite_assemble.nodes[node_id].change_state -1]
				sucess = true
			
			Types.CONDITION:
				if code_names.conditions.is_empty():
					pass # Cognite.emit_alert(TEXT_ERROR_FAIL_CONDITION)
				
				var new_condition = code_names.conditions[cognite_assemble.nodes[node_id].condition -1]
				routine[key][new_condition] = new_routine
				
				var result = condition_routine(cognite_assemble.nodes[node_id], new_routine, code_names, cognite_assemble)
				if result:
					return result
				sucess = true
			
			Types.RANGE:
				if code_names.ranges.is_empty():
					pass # Cognite.emit_alert(TEXT_ERROR_FAIL_RANGE)
				
				var new_range = code_names.ranges[cognite_assemble.nodes[node_id].range -1]
				routine[key][new_range] = new_routine
				
				var result = range_routine(cognite_assemble.nodes[node_id], new_routine, code_names, cognite_assemble)
				if result:
					return result
				sucess = true
			
			Types.EVENTS:
				if code_names.signal.is_empty():
					pass # Cognite.emit_alert(TEXT_ERROR_FAIL_EVENT)
				
				var new_event = code_names.signal[cognite_assemble.nodes[node_id].trigger -1]
				if event_routine(cognite_assemble.nodes[node_id], new_routine, code_names, cognite_assemble):
					continue
				
				routine[key] = new_routine
				return code_names.signal[cognite_assemble.nodes[node_id].trigger -1]
	if not sucess:
		return true

## IN GAME #########################################################################################

static func process_routine_to_callable(routine: Dictionary, propertie_names: Dictionary, cognite_node: CogniteNode):
	if not routine.body: return
	
	var assembly := RoutineAsemblyProcess.new()
	
	var state_id: int = propertie_names.state.find(routine.modus)
	if state_id == -1:
		print("ERROR: propertie_names.state.find(routine.modus): ", routine.modus)
		return
	else: assembly.modus = state_id
	
	var calls = get_routine_members(routine.body, propertie_names, cognite_node)
	if not calls is Callable:
		return
	
	assembly.assemble = calls
	return assembly

static func event_routine_to_callable(routine: Dictionary, propertie_names: Dictionary, cognite_node: CogniteNode):
	if not routine.body: return
	
	var assembly := RoutineAsemblyEvent.new()
	var state_id: int = propertie_names.state.find(routine.modus)
	if state_id == -1:
		print("ERROR: propertie_names.state.find(routine.modus): ", routine.modus)
		return
	else: assembly.modus = state_id
	
	if not cognite_node.variables.has(routine.event):
		print("ERROR: cognite_node.variables.has(routine.event): ", routine.event)
		return
	
	var calls = get_routine_members(routine.body, propertie_names, cognite_node)
	if not calls is Callable:
		return
	
	assembly.assemble = calls
	assembly.cognite_node = cognite_node
	assembly.event = cognite_node.variables[routine.event]
	
	return assembly

static func get_routine_members(body: Dictionary, propertie_names: Dictionary, cognite_node: CogniteNode):
	var call_result: Array[Callable]
	
	for member in body:
		var calls: Array[Callable]
		
		if member == "value":
			continue
		
		if member == "body":
			var state_id: int = propertie_names.state.find(body[member])
			if state_id == -1:
				continue
			calls.append(cognite_node.change_state.bind(state_id))
		else:
			if body[member].has("ifs"):
				_procedural_callable_generation(
					body[member].ifs, Callable(func(): return cognite_node.get(member)), propertie_names, cognite_node, calls
				)
				
				#var member_calls = get_routine_members(body[member].ifs, propertie_names, cognite_node)
				#if member_calls is Callable:
					#var condition := Callable(func(): return cognite_node.get(member))
					#var call = Callable(CogniteData._meta_call.bind(condition, member_calls))
					#calls.append(call)
				
				if body[member].has("else"):
					_procedural_callable_generation(
						body[member].else, Callable(func(): return not cognite_node.get(member)), propertie_names, cognite_node, calls
					)
					#var member_calls_else = get_routine_members(body[member].else, propertie_names, cognite_node)
					#if member_calls_else is Callable:
						#var condition_else := Callable(func(): return not cognite_node.get(member))
						#var call_else = Callable(CogniteData._meta_call.bind(condition_else, member_calls_else))
						#calls.append(call_else)
			
			elif body[member].has("else"):
				_procedural_callable_generation(
					body[member].else, Callable(func(): return not cognite_node.get(member)), propertie_names, cognite_node, calls
				)
				#var member_calls = get_routine_members(body[member].else, propertie_names, cognite_node)
				#if member_calls is Callable:
					#var condition := Callable(func(): return not cognite_node.get(member))
					#var call = Callable(CogniteData._meta_call.bind(condition, member_calls))
					#calls.append(call)
			
			if body[member].has("bigger"):
				_procedural_callable_generation(
					body[member].bigger,
					Callable(func(): return cognite_node.get(member) > body[member].bigger.value),
					propertie_names, cognite_node, calls
				)
				#var member_calls = get_routine_members(body[member].bigger, propertie_names, cognite_node)
				#if member_calls is Callable:
					#var condition := Callable(func(): return cognite_node.get(member))
					#var call = Callable(CogniteData._meta_call.bind(condition, member_calls))
					#calls.append(call)
			
			if body[member].has("smaller"):
				_procedural_callable_generation(
					body[member].smaller,
					Callable(func(): return cognite_node.get(member) < body[member].smaller.value),
					propertie_names, cognite_node, calls
				)
		
		call_result.append(
			Callable(
				func(_calls: Array[Callable]): for _call in _calls: _call.call()
			).bind(calls)
		)
	
	var callable := Callable(func(_calls): for _call in _calls: _call.call()).bind(call_result)
	return callable

static func _meta_call(condition: Callable, _call: Callable):
	if condition.call():
		_call.call()

static func _procedural_callable_generation(body: Dictionary, condition: Callable, propertie_names: Dictionary, cognite_node: CogniteNode, calls: Array[Callable]):
	var member_calls = get_routine_members(body, propertie_names, cognite_node)
	if member_calls is Callable:
		var call = Callable(CogniteData._meta_call.bind(condition, member_calls))
		calls.append(call)

####################################################################################################

static func except_letters(input_string: String) -> String:
	var regex := RegEx.new()
	regex.compile("[^A-Za-z_]") 
	input_string = regex.sub(input_string, "")
	input_string = input_string.replace(" ", "_")
	return input_string
