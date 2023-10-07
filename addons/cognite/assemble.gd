@tool
class_name CogniteAssemble extends Resource

enum {MODUS, EVENTS, CHANGE_STATE, CONDITION}

@export var nodes: Dictionary
@export var source: CogniteSource


func get_assembly() -> GDScript:
	var gdscript := "@tool\nextends Node\n\n"
	var state_list: PackedStringArray
	var signal_list: PackedStringArray
	var condition_list: PackedStringArray
	
	gdscript += "enum State {\n"
	gdscript += "	STATELESS,\n"
	
	gdscript += get_state_list(state_list) + "}\n\n"
	gdscript += "signal state_changed(state)\n"
	gdscript += get_triggers_list(signal_list) + "\n"
	gdscript += get_condition_list(condition_list)
	
	gdscript += "\n@export var cognite_assemble: CogniteAssemble\n\n"
	gdscript += "\n@export var current_state: State = State.STATELESS\n"
	
	gdscript += "\n\n"
	
	var capsules: Dictionary
	for node_id in nodes[1].right_connections:
		search_signal_routine(node_id, capsules, [state_list, condition_list, signal_list])
	
	print(capsules)
	
	gdscript += "func _ready():
	if Engine.is_editor_hint():
		return\n\n"
	
	for capsule in capsules:
		gdscript += "	"+ capsules[capsule].func + ".connect(_on_" + capsules[capsule].func + ")\n"
	
	gdscript += "\n\nfunc _process(delta):
	if Engine.is_editor_hint():
		return\n\n"
	
	for node_id in nodes[1].right_connections:
		gdscript += routine_test_modus_process(nodes[node_id].state, node_id, [state_list, condition_list])
		gdscript += "\n"
	
	for node_id in nodes:
		if nodes[node_id]:
			gdscript
	
	gdscript += "\n\n"
	
	for capsule in capsules:
		gdscript += "func _on_" + capsule + "():"
		for modus in capsules[capsule].body:
			gdscript += "\n	if current_state == State." + state_list[modus -1] + ":\n"
			
			for body in capsules[capsule].body[modus]:
				gdscript += "		" + body + "\n"
		
		gdscript += "\n"
	
	gdscript += "\n\nfunc change_state(new_state: State):
	if current_state == new_state:
		return
	
	current_state = new_state
	state_changed.emit(current_state)
	"
	
	gdscript += "\n\n"
	
	gdscript += "
func assembly():
	if cognite_assemble:
		cognite_assemble.get_assembly()
		var assembly_code: GDScript = load(\"res://addons/cognite/sources/temp_code.gd\")
		set_script(assembly_code)
		set_assemble.call_deferred(assembly_code)


func set_assemble(data: CogniteAssemble):
	cognite_assemble = data
	name = \"CogniteNodeAssembly\"


func is_cognite_node():
	pass
"
	
	var code := GDScript.new()
	code.source_code = gdscript
	code.reload()
	
	ResourceSaver.save(code, "res://addons/cognite/sources/temp_code.gd")
	
	return code


func get_state_list(state_list: PackedStringArray):
	var count := 0
	var code: String
	
	for state in source.states:
		state_list.append(except_letters(state).to_upper())
		code += "	" + state_list[count] + ",\n"
		count += 1
	return code

func get_triggers_list(state_list: PackedStringArray):
	var count := 0
	var code: String
	
	for trigger in source.triggers:
		state_list.append(except_letters(trigger))
		code += "signal " + state_list[count] + "\n"
		count += 1
	return code

func get_condition_list(state_list: PackedStringArray):
	var count := 0
	var code: String
	
	for condition in source.conditions:
		state_list.append(except_letters(condition))
		code += "var " + state_list[count] + ": bool\n"
		count += 1
	return code


func routine_test_modus_process(state, node_id, static_lists: Array[PackedStringArray]) -> String:
	var current_state_code: String
	var routine_list: Array[String]
	
	for _node_id in nodes[node_id].right_connections:
		var current_routine_list: String
		if not nodes.has(_node_id):
			continue
		
		if nodes[_node_id].type == CONDITION:
			current_routine_list += routine_test_condition_process(nodes[_node_id].condition, _node_id, 2, static_lists)
		
		elif nodes[_node_id].type == CHANGE_STATE:
			current_routine_list += routine_test_change_state_process(nodes[_node_id].change_state, static_lists)
		
		if not current_routine_list.is_empty():
			routine_list.append(current_routine_list)
	
	if not routine_list.is_empty():
		current_state_code = "	if current_state == State." + static_lists[0][state -1] + ":"
		for routine in routine_list:
			current_state_code += "		" + routine + "\n"
	
	return current_state_code

func routine_test_condition_process(value: int, node_id: int, identation_level: int, static_lists: Array[PackedStringArray]) -> String:
	var current_code: String
	var path_true: Array[String]
	var path_false: Array[String]
	
	for _node_id in nodes[node_id].right_connections:
		var condition_process: String
		
		if not nodes.has(_node_id):
			continue
		
		if nodes[_node_id].type == CHANGE_STATE:
			condition_process = routine_test_change_state_process(nodes[_node_id].change_state, static_lists)
		
		elif nodes[_node_id].type == CONDITION:
			condition_process = routine_test_condition_process(nodes[_node_id].condition, _node_id, identation_level + 1, static_lists)
		
		if condition_process.is_empty():
			continue
		
		if nodes[node_id].right_connections[_node_id].x == 1:
			path_false.append(condition_process)
		else:
			path_true.append(condition_process)
	
	if not path_true.is_empty():
		current_code += "\n"
		for i in identation_level:
			current_code += "	"
		
		current_code += "if " + static_lists[1][value -1] + ": "
		
		for path in path_true:
			current_code += path + ";"
		
		if not path_false.is_empty():
			current_code += "\n"
			
			for i in identation_level:
				current_code += "	"
			
			current_code += "else: "
			
			for path in path_false:
				current_code += path + ";"
	
	elif not path_false.is_empty():
		current_code += "if not " + static_lists[1][value -1] + ": "
		for path in path_false:
			current_code += path + ";"
	
	return current_code

func routine_test_change_state_process(value, static_lists: Array[PackedStringArray]) -> String:
	return "change_state(State." + static_lists[0][value -1] + ")"


func search_signal_routine(node_id, capsules: Dictionary, static_lists: Array[PackedStringArray]):
	var modus = nodes[node_id].state
	for _node_id in nodes[node_id].right_connections:
		if not nodes.has(_node_id):
			continue
		
		if nodes[_node_id].type == EVENTS:
			var capsule = signal_routine(_node_id, modus, static_lists)
			if capsule:
				if capsules.has(capsule.func):
					for _modus in capsule.body:
						capsules[capsule.func].body[_modus] = capsule.body[_modus]
				else:
					capsules[capsule.func] = capsule
		
		if nodes[_node_id].type == EVENTS:
			pass

func signal_routine(node_id: int, modus, static_lists: Array[PackedStringArray]):
	var capsule := {
		"func": static_lists[2][nodes[node_id].trigger -1],
		"body": {
			modus: []
		}
	}
	
	for _node_id in nodes[node_id].right_connections:
		if nodes[_node_id].type == CONDITION:
			var current_route: Array
			if signal_routine_condition(_node_id, current_route, static_lists):
				return
			
			print(current_route)
			print()
			
			if not current_route.is_empty():
				capsule.body[modus].append(current_route[0])
			
			print(capsule.body[modus])
		
		elif nodes[_node_id].type == CHANGE_STATE:
			capsule.body[modus].append(routine_test_change_state_process(nodes[_node_id].change_state, static_lists) + "; ")
		
		elif nodes[_node_id].type == EVENTS:
			return
	
	return capsule

func signal_routine_condition(node_id: int, current_route: Array, static_lists: Array[PackedStringArray]):
	if current_route.is_empty():
		current_route.append("		if " + static_lists[1][nodes[node_id].condition -1])
	else:
		current_route[0] += " and " + static_lists[1][nodes[node_id].condition -1]
	
	var _match := false
	for _node_id in nodes[node_id].right_connections:
		if nodes[_node_id].type == CONDITION:
			_match = true
			if signal_routine_condition(_node_id, current_route, static_lists):
				return true
		
		elif nodes[_node_id].type == CHANGE_STATE:
			if _match == false:
				current_route[0] += ": "
			_match = true
			
			current_route[0] += routine_test_change_state_process(nodes[_node_id].change_state, static_lists) + "; "
		
		elif nodes[_node_id].type == EVENTS:
			return true
	
	if not _match:
		current_route[0] += ": pass"


func except_letters(input_string: String) -> String:
	var regex := RegEx.new()
	regex.compile("[^A-Za-z_]")  # Esta expressão regular corresponde a qualquer caractere que não seja uma letra ou underline.
	input_string = regex.sub(input_string, "")  # Substitui os caracteres especiais por uma string vazia.
	input_string = input_string.replace(" ", "_")
	return input_string


func is_cognite_assemble():
	return true

