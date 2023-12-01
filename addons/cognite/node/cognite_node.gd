@tool
class_name CogniteNode extends Node


@export var cognite_assemble_root: CogniteAssemble:
	set(value):
		if cognite_assemble_root != value:
			value.actualized.connect(actualized)
		cognite_assemble_root = value

var root_node: Node
var is_active := true
var updating: bool

var propertie_names: Dictionary
var variables: Dictionary
var decompress: Dictionary


func _ready():
	if not Engine.is_editor_hint():
		actualized()


func actualized():
	if updating: return
	updating = true
	
	propertie_names = CogniteData.get_propertie_names(cognite_assemble_root)
	var routines: Array = CogniteData.create_routines(cognite_assemble_root, propertie_names)
	
	var count: int
	for names in propertie_names.state:
		var _names: String = names
		
		decompress[names] = []
		variables[_names.to_upper()] = count
		count += 1
	
	for names in propertie_names.conditions:
		variables[names] = false
	
	for names in propertie_names.ranges:
		variables[names] = 0.0
	
	for names in propertie_names.signal:
		var _signal := Signal(self, names)
		variables[names] = _signal
	
	for routine in routines:
		decompress[routine.modus].append(routine)
	
	
	
	set_deferred("updating", false)


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
		property_list.append({"name": _signal, "type": TYPE_SIGNAL, "usage": PROPERTY_USAGE_SCRIPT_VARIABLE})
	
	return property_list



func is_cognite_node(): pass
