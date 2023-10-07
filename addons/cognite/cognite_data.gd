@tool
class_name CogniteData extends RefCounted

const ROUTINE_SEARCH_FAIL := true
const CODE_PROPERTY_NAMES := {"state": [], "signal": [], "conditions": []}
const CODE_HEAD := "extends CogniteNodeAssembly\n"
const CODE_EXPORT := "\n@export var current_state: State\n@onready var initial_state = current_state\n"
const CODE_PARENT_CHANGED_SIGNAL := "	get_parent().state_changed.connect(_parent_state_changed)\n"
const CODE_READY := "func _ready():
	pass\n\n"
const CODE_PROCESS := "\n\nfunc _process(delta):
	pass\n\n"
const CODE_ROUTINE_DATA := {
	"modus": "", "event": "", "body": {},
}
const CODE_CHANGE_STATE := "\n
func change_state(new_state):
	if new_state == current_state:
		return
	
	if not is_active:
		current_state = State.STATELESS
	
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


static func assembly(cognite_assemble: CogniteAssemble, relative_parent_state: int):
	var code_names := CogniteData.CODE_PROPERTY_NAMES.duplicate(true)
	var code := CogniteData.CODE_HEAD
	
	for state in cognite_assemble.source.states:
		code_names.state.append(except_letters(state).to_upper())
	
	for trigger in cognite_assemble.source.triggers:
		code_names.signal.append(except_letters(trigger))
	
	for condition in cognite_assemble.source.conditions:
		code_names.conditions.append(except_letters(condition))
	
	code += get_states(code_names)
	code += get_signals(code_names)
	code += CogniteData.CODE_EXPORT
	code += get_conditions(code_names)
	
	code += "\nvar is_active := true\n"
	if relative_parent_state != 0:
		code += "\nvar relative_parent_state: int\n"
	
	var routines: Array
	for node in cognite_assemble.nodes.values():
		if node.type == CogniteAssemble.MODUS:
			get_routines(node, routines, code_names, cognite_assemble)
	
	var events: Dictionary
	mont_signals(routines, events)
	
	code += CogniteData.CODE_READY
	
	if relative_parent_state != 0:
		code += CogniteData.CODE_PARENT_CHANGED_SIGNAL
		code += "\n	relative_parent_state = " + str(relative_parent_state) + "\n\n"
	
	for event in events:
		code += "	" + event + ".connect(_on_" + event + ")\n"
	
	code += CogniteData.CODE_PROCESS
	
	for routine in routines:
		if not routine.event.is_empty():
			continue
		
		code += "\n	if current_state == State." + routine.modus + ":\n"
		code += build_routine(routine.body, 2)
	
	code += CogniteData.CODE_CHANGE_STATE
	if relative_parent_state != 0:
		code += CogniteData.CODE_PARENT_CHANGED_RECEIVER
	
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
	code += "\n"
	return code

static func get_routines(node_modus: Dictionary, routines: Array, code_names: Dictionary, cognite_assemble: CogniteAssemble):
	for node_id in node_modus.right_connections:
		var routine := CogniteData.CODE_ROUTINE_DATA.duplicate(true)
		
		if not cognite_assemble.nodes.has(node_id):
			continue
		
		match cognite_assemble.nodes[node_id].type:
			CogniteAssemble.CHANGE_STATE:
				routine.modus = code_names.state[node_modus.state -1]
				
				var state: String = code_names.state[cognite_assemble.nodes[node_id].change_state -1]
				routine.body["body"] = "change_state(State." + state + ")\n"
			
			CogniteAssemble.CONDITION:
				var new_condition = code_names.conditions[cognite_assemble.nodes[node_id].condition -1]
				var _condition_routine: Dictionary
				
				if condition_routine(cognite_assemble.nodes[node_id], _condition_routine, code_names, cognite_assemble):
					continue
				
				routine.modus = code_names.state[node_modus.state -1]
				routine.body = {new_condition: _condition_routine}
			
			CogniteAssemble.EVENTS:
				var new_event = code_names.signal[cognite_assemble.nodes[node_id].trigger -1]
				routine.event = new_event
				var event_routine: Dictionary
				
				for _node_id in cognite_assemble.nodes[node_id].right_connections:
					match cognite_assemble.nodes[_node_id].type:
						CogniteAssemble.CHANGE_STATE:
							var state: String = code_names.state[cognite_assemble.nodes[_node_id].change_state -1]
							event_routine["body"] = "change_state(State." + state + ")\n"
						
						CogniteAssemble.CONDITION:
							var new_condition = code_names.conditions[cognite_assemble.nodes[_node_id].condition -1]
							var _condition_routine: Dictionary
							
							if condition_routine(cognite_assemble.nodes[_node_id], _condition_routine, code_names, cognite_assemble):
								continue
							
							event_routine = {new_condition: _condition_routine}
						
						CogniteAssemble.EVENTS:
							continue
				
				routine.modus = code_names.state[node_modus.state -1]
				routine.body = event_routine
		
		routines.append(routine)

static func condition_routine(node: Dictionary, routine: Dictionary, code_names: Dictionary, cognite_assemble: CogniteAssemble):
	for node_id in node.right_connections:
		var key = "else" if node.right_connections[node_id].x == 1 else "ifs"
		var new_routine: Dictionary
		
		routine[key] = {}
		
		match cognite_assemble.nodes[node_id].type:
			CogniteAssemble.CHANGE_STATE:
				var state: String = code_names.state[cognite_assemble.nodes[node_id].change_state -1]
				routine[key]["body"] = "change_state(State." + state + ")\n"
			
			CogniteAssemble.CONDITION:
				var new_condition = code_names.conditions[cognite_assemble.nodes[node_id].condition -1]
				routine[key][new_condition] = new_routine
				
				if condition_routine(cognite_assemble.nodes[node_id], new_routine, code_names, cognite_assemble):
					return ROUTINE_SEARCH_FAIL
				
			CogniteAssemble.EVENTS:
				return ROUTINE_SEARCH_FAIL

static func build_routine(body: Dictionary, identation: int):
	var code: String
	
	if body.has("body"):
		code += "	".repeat(identation) + body.body
	
		if body.body is String:
			return code
	
	for condition in body:
		if body[condition].has("ifs"):
			code += "	".repeat(identation) + "if "+ condition + ":\n"
			code += build_routine(body[condition].ifs, identation + 1)
			
			if body[condition].has("else"):
				code += "	".repeat(identation) + "else:\n"
				code += build_routine(body[condition].else, identation + 1)
		
		elif body[condition].has("else"):
			code += "	".repeat(identation) + "if not "+ condition + ":\n"
			code += build_routine(body[condition].else, identation + 1)
	
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
	regex.compile("[^A-Za-z_]")  # Esta expressão regular corresponde a qualquer caractere que não seja uma letra ou underline.
	input_string = regex.sub(input_string, "")  # Substitui os caracteres especiais por uma string vazia.
	input_string = input_string.replace(" ", "_")
	return input_string
