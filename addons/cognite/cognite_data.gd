@tool
class_name CogniteData extends RefCounted

enum Types {MODUS, EVENTS, CHANGE_STATE, CONDITION, RANGE, CHANGE_PROPERTY}

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

class RoutineAsemblyProcess extends RoutineAsembly:
	func process(state: int):
		if modus == state and not assemble.is_null():
			assemble.call()

class RoutineAsemblyEvent extends RoutineAsembly:
	var cognite_node: CogniteNode
	
	func get_modus():
		if cognite_node._current_state == modus and not assemble.is_null():
			assemble.call()

static func get_propertie_names(cognite_assemble: CogniteAssemble) -> Dictionary:
	var propertie_names := CODE_PROPERTY_NAMES.duplicate(true)
	
	if not cognite_assemble.nodes.is_empty():
		for id in cognite_assemble.nodes:
			var node: Dictionary = cognite_assemble.nodes[id]
			
			match node.type:
				Types.MODUS:
					if node.has("state") and not propertie_names.state.has(node.state):
						propertie_names.state.append(node.state)
				
				Types.EVENTS:
					if node.has("trigger") and not propertie_names.signal.has(node.trigger):
						propertie_names.signal.append(node.trigger)
				
				Types.CONDITION:
					if node.has("condition") and not propertie_names.conditions.has(node.condition):
						propertie_names.conditions.append(node.condition)
				
				Types.RANGE:
					if node.has("range") and not propertie_names.ranges.has(node.range):
						propertie_names.ranges.append(node.range)
	
	return propertie_names

static func create_routines(cognite_assemble: CogniteAssemble, propertie_names: Dictionary) -> Array:
	var routines: Array
	for node in cognite_assemble.nodes.values():
		if node.type == Types.MODUS:
			get_routines(node, routines, propertie_names, cognite_assemble)
	return routines

## DECOMPOSE #######################################################################################

static func create_sub_routines(node_data: Dictionary, body: Dictionary, code_names: Dictionary, cognite_assemble: CogniteAssemble):
	var new_routine: Dictionary
	var sucess: bool
	
	match node_data.type:
		Types.CHANGE_STATE:
			body["state"] = node_data.change_state
			sucess = true
			
		Types.CHANGE_PROPERTY:
			var _type: int = node_data.properties
			var result: Array
			
			result.append(_type)
			result.append(node_data.property)
			result.append(node_data.condition if _type == 0 else node_data.range)
			
			body["property"] = result
			sucess = true
			
		Types.CONDITION:
			if code_names.conditions.is_empty():
				pass # Cognite.emit_alert(TEXT_ERROR_FAIL_CONDITION)
			
			body[node_data.condition] = new_routine
			
			var result = condition_routine(node_data, new_routine, code_names, cognite_assemble)
			if result:
				return result
			
			sucess = true
			
		Types.RANGE:
			var new_range = node_data.range
			body[new_range] = new_routine
			
			var result = range_routine(node_data, new_routine, code_names, cognite_assemble)
			if result:
				return result
			sucess = true
			
		Types.EVENTS:
			if event_routine(node_data, new_routine, code_names, cognite_assemble):
				return 48
			
			body["body"] = new_routine
			return node_data.trigger
	
	if not sucess:
		return true

static func get_routines(node_modus: Dictionary, routines: Array, code_names: Dictionary, cognite_assemble: CogniteAssemble):
	for node_id in node_modus.right_connections:
		var routine := CODE_ROUTINE_DATA.duplicate(true)
		
		if not cognite_assemble.nodes.has(node_id):
			continue
		
		routine.modus = node_modus.state
		
		var result = create_sub_routines(cognite_assemble.nodes[node_id], routine.body, code_names, cognite_assemble)
		
		if result is String and routine.event.is_empty():
			routine.event = result
		
		routines.append(routine)

static func event_routine(event: Dictionary, _event_routine: Dictionary, code_names: Dictionary, cognite_assemble: CogniteAssemble):
	var sucess: bool
	for _node_id in event.right_connections:
		if not cognite_assemble.nodes.has(_node_id):
			continue
		
		var result = create_sub_routines(cognite_assemble.nodes[_node_id], _event_routine, code_names, cognite_assemble)
		
		if result is String:
			return true
		
		elif result is int and result == 48:
			_event_routine = {}
			continue
			
		elif result == null:
			sucess = true
		
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
		
		var result = create_sub_routines(cognite_assemble.nodes[node_id], routine[key], code_names, cognite_assemble)
		
		if result is String:
			return result
		
		elif result is int and result == 48:
			routine[key] = {"value": node[key]}
			continue
			
		elif result == null:
			sucess = true
	
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
		
		var result = create_sub_routines(cognite_assemble.nodes[node_id], routine[key], code_names, cognite_assemble)
		
		if result is String:
			return result
		
		elif result == 48:
			routine[key] = {}
			continue
			
		elif result == null:
			sucess = true
		
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
		print("ERROR: event_routine_to_callable: calls = get_routine_members")
		return
	
	assembly.assemble = calls
	assembly.cognite_node = cognite_node
	cognite_node.variables[routine.event].callables.append(assembly.get_modus)
	
	return assembly

static func get_routine_members(body: Dictionary, propertie_names: Dictionary, cognite_node: CogniteNode):
	var call_result: Array[Callable]
	
	for member in body:
		var calls: Array[Callable]
		
		if member == "value":
			continue
		
		elif member == "state":
			var state_id: int = propertie_names.state.find(body[member])
			if state_id == -1:
				continue
			calls.append(cognite_node._change_state.bind(state_id))
		
		elif member == "property":
			var array: Array = body[member]
			calls.append(cognite_node.set.bind(array[1], array[2]))
		
		elif member == "body":
			_procedural_callable_generation(
				body[member], Callable(func(): return true), propertie_names, cognite_node, calls
			)
		
		else:
				
			if body[member].has("ifs"):
				_procedural_callable_generation(
					body[member].ifs, Callable(func(): return cognite_node.get(member)), propertie_names, cognite_node, calls
				)
				if body[member].has("else"):
					_procedural_callable_generation(
						body[member].else, Callable(func(): return not cognite_node.get(member)), propertie_names, cognite_node, calls
					)
			elif body[member].has("else"):
				_procedural_callable_generation(
					body[member].else, Callable(func(): return not cognite_node.get(member)), propertie_names, cognite_node, calls
				)
			if body[member].has("bigger"):
				_procedural_callable_generation(
					body[member].bigger,
					Callable(func(): return cognite_node.get(member) > body[member].bigger.value),
					propertie_names, cognite_node, calls
				)
			if body[member].has("smaller"):
				_procedural_callable_generation(
					body[member].smaller,
					Callable(func(): return cognite_node.get(member) < body[member].smaller.value),
					propertie_names, cognite_node, calls
				)
		
		call_result.append(Callable(func(): for _call in calls: _call.call()))
	
	var callable := Callable(func(): for _call in call_result: _call.call())
	return callable

static func _procedural_callable_generation(body: Dictionary, condition: Callable, propertie_names: Dictionary, cognite_node: CogniteNode, calls: Array[Callable]):
	var member_calls = get_routine_members(body, propertie_names, cognite_node)
	if member_calls is Callable:
		var call = Callable(func(): if condition.call(): member_calls.call())
		calls.append(call)

####################################################################################################

static func except_letters(input_string: String) -> String:
	var regex := RegEx.new()
	regex.compile("[^A-Za-z_]") 
	input_string = regex.sub(input_string, "")
	input_string = input_string.replace(" ", "_")
	return input_string
