@tool
class_name CogniteRuntimeAction extends RefCounted


var cognite_node: CogniteNode
var runtime_decision: CogniteRuntimeDecision


func _init(action: Dictionary, _cognite_node: CogniteNode) -> void:
	cognite_node = _cognite_node;
	runtime_decision = cognite_node.runtime_decision[action.decision_id]
	
	for deed_id in action.deed_list:
		var deed: Dictionary = cognite_node.cognite_assemble.deeds[deed_id]
		deed.name
		deed.process_mode
	
	
