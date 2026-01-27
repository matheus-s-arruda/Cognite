@tool
class_name CogniteRuntimeDecision extends RefCounted

var runtime_context: Dictionary
var scores: Dictionary

var current_score: int


func _init(decision: Dictionary, cognite_node: CogniteNode) -> void:
	current_score = decision.base_score
	
	for context_id in decision.context_ids:
		scores[context_id] = decision.context_ids[context_id]
		runtime_context[context_id] = cognite_node.runtime_context[context_id]


func get_score() -> int:
	var score: int = current_score
	
	for context_id in runtime_context:
		if runtime_context[context_id].validate:
			score += scores[context_id]
	
	return score
