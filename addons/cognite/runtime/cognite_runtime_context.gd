@tool
class_name CogniteRuntimeContext extends RefCounted

enum PropertyType {BOOL, EQUAL, LESS, MORE, BETWEEN}

var cognite_node: CogniteNode
var perpection_list: Array[Callable]

var validate: bool


func _init(context: Dictionary, assemble: CogniteAssemble, _cognite_node: CogniteNode) -> void:
	cognite_node = _cognite_node;
	
	for perception_id in context.perception_ids:
		var perception: Dictionary = assemble.perceptions[perception_id]
		match perception.type:
			PropertyType.BOOL: perpection_list.append(Callable(self, "test_perception_is").bind(perception.name, bool(perception.prop1)))
			PropertyType.EQUAL: perpection_list.append(Callable(self, "test_perception_is").bind(perception.name, perception.prop1))
			PropertyType.LESS: perpection_list.append(Callable(self, "test_perception_less").bind(perception.name, perception.prop1))
			PropertyType.MORE: perpection_list.append(Callable(self, "test_perception_more").bind(perception.name, perception.prop1))
			PropertyType.BETWEEN: perpection_list.append(Callable(self, "test_perception_between").bind(perception.name, perception.prop1, perception.prop2))


func is_valid():
	for perception in perpection_list:
		if not perception.call():
			validate = false
			return
	
	validate = true


func test_perception_is(perception_name: StringName, value):
	return cognite_node.get(perception_name) == value


func test_perception_less(perception_name: StringName, value: float):
	return cognite_node.get(perception_name) < value


func test_perception_more(perception_name: StringName, value: float):
	return cognite_node.get(perception_name) > value


func test_perception_between(perception_name: StringName, value1: float, value2: float):
	return cognite_node.get(perception_name) > value1 and cognite_node.get(perception_name) < value2 
