@tool
class_name CogniteNode extends Node

signal state_changed(state)

@export var cognite_assemble_root: CogniteAssemble:
	set(value):
		if cognite_assemble_root != value:
			if cognite_assemble_root:
				cognite_assemble_root.actualized.disconnect(actualize)
			
			if value:
				value.actualized.connect(actualize)
		
		cognite_assemble_root = value

class FakeSignal:
	var callable: Callable
	func emit():
		if callable:
			callable.call()

var root_node: Node
var is_active := true
var updating: bool

var propertie_names: Dictionary
var variables: Dictionary
var routines: Array

var decompressed_process: Array
var decompressed_event: Array

var current_state: int = -1
var assembly_process: Array
var assembly_event: Array


func actualize():
	if not cognite_assemble_root:
		return
	
	if updating: return
	updating = true
	
	variables.clear()
	decompressed_event.clear()
	decompressed_process.clear()
	
	propertie_names = CogniteData.get_propertie_names(cognite_assemble_root)
	routines = CogniteData.create_routines(cognite_assemble_root, propertie_names)
	
	for routine in routines:
		if routine.event:
			decompressed_event.append(routine)
		else:
			decompressed_process.append(routine)
	
	var count: int
	for names in propertie_names.state:
		var _names: String = names
		variables[_names] = count
		count += 1
	
	for names in propertie_names.conditions:
		variables[names] = false
	
	for names in propertie_names.ranges:
		variables[names] = 0.0
	
	for names in propertie_names.signal:
		var _signal := FakeSignal.new()
		variables[names] = _signal
	
	set_deferred("updating", false)


## IN GAME #########################################################################################
func _ready():
	if Engine.is_editor_hint():
		return
	
	actualize()
	
	for routine in decompressed_process:
		var assemble = CogniteData.process_routine_to_callable(routine, propertie_names, self)
		if assemble:
			assembly_process.append(assemble)
	
	for routine in decompressed_event:
		var assemble = CogniteData.event_routine_to_callable(routine, propertie_names, self)
		if assemble:
			assembly_event.append(assemble)
	
	get_children().map(func(child): child.set_process(false); child.set_physics_process(false))
	
	change_state(0)


func change_state(new_state: int):
	if new_state != current_state:
		current_state = new_state
		state_changed.emit(current_state)
		get_children().map(set_child_behavior_enabled)


func set_child_behavior_enabled(child: Node):
	child.set_process(false)
	child.set_physics_process(false)
	
	if not cognite_assemble_root or not cognite_assemble_root.source:
		return
	
	if not cognite_assemble_root.source.states.has(child.name):
		return
	
	if child.name == variables.find_key(current_state):
		if child.has_method("start"):
			child.start()
		
		child.set_process(true)
		child.set_physics_process(true)


func _process(delta):
	if not Engine.is_editor_hint():
		for assemble in assembly_process:
			assemble.process(current_state)

## META ############################################################################################
func _get(property):
	if not propertie_names.is_empty():
		for names in propertie_names:
			if propertie_names[names].has(property):
				return variables[property]

func _set(property, value):
	if not propertie_names.is_empty():
		for names in propertie_names:
			if propertie_names[names].has(property):
				variables[property] = value
				return true
	return false

func _get_property_list():
	var property_list: Array[Dictionary]
	if propertie_names.is_empty():
		return property_list
	
	for condition in propertie_names.conditions:
		property_list.append({"name": condition, "type": TYPE_BOOL, "usage": PROPERTY_USAGE_SCRIPT_VARIABLE})
	for range in propertie_names.ranges:
		property_list.append({"name": range, "type": TYPE_FLOAT, "usage": PROPERTY_USAGE_SCRIPT_VARIABLE})
	for state in propertie_names.state:
		property_list.append({"name": state, "type": TYPE_INT, "usage": PROPERTY_USAGE_SCRIPT_VARIABLE})
	for _signal in propertie_names.signal:
		property_list.append({"name": _signal, "type": TYPE_OBJECT, "usage": PROPERTY_USAGE_SCRIPT_VARIABLE})
	
	return property_list

func is_cognite_node(): pass

####################################################################################################
