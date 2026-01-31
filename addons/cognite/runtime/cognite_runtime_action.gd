@tool
class_name CogniteRuntimeAction extends RefCounted


var cognite_node: CogniteNode
var runtime_decision: CogniteRuntimeDecision

var deed_signals_initiated: Dictionary
var deed_signals_finalized: Dictionary


class CogniteRuntimeDeed extends RefCounted:
	var process_mode: int
	var deed: Dictionary
	
	func _init(_deed: Dictionary):
		deed = _deed
		Signal(self, "_on_" + deed.name + "_initiated")
		Signal(self, "_on_" + deed.name + "_finalized")
	
	


func _init(action: Dictionary, _cognite_node: CogniteNode) -> void:
	cognite_node = _cognite_node;
	runtime_decision = cognite_node.runtime_decision[action.decision_id]
	
	for deed_id in action.deed_list:
		var deed: Dictionary = cognite_node.cognite_assemble.deeds[deed_id]
		deed_signals_initiated[deed_id] = [Signal(cognite_node, "_on_" + deed.name + "_initiated"), deed.process_mode]
		deed_signals_finalized[deed_id] = Signal(cognite_node, "_on_" + deed.name + "_finalized")
	
	
