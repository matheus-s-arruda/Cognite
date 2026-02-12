@tool
class_name CogniteRuntimeAction extends RefCounted

enum DeedSignal {STARTED, FINALIZED, REQUEST}
enum ProcessMode {CASCADE =  1, PARALLEL = 2}

var cognite_node: CogniteNode
var runtime_decision: CogniteRuntimeDecision

var deeds: Dictionary
var deeds_by_name: Dictionary
var queue_process_group: Dictionary
var current_process: int
var queue_process_size: int
var queue_process_keys: Array
var queue_process_deeds: Array 


func _init(action: Dictionary, _cognite_node: CogniteNode) -> void:
	cognite_node = _cognite_node;
	runtime_decision = cognite_node.runtime_decision[action.decision_id]
	
	for deed_id in action.deed_list:
		var deed: Dictionary = cognite_node.cognite_assemble.deeds[deed_id]
		deeds_by_name[deed.name] = deed_id
		deeds[deed_id] = CogniteRuntimeDeed.new(deed.name)
		queue_process_group[deed_id] = deed.process_mode
		queue_process_size += 1
	
	queue_process_keys = queue_process_group.keys()


func start():
	current_process = 0
	
	for deed_id in deeds:
		var deed: CogniteRuntimeDeed = deeds[deed_id]
		if not deed.started.is_connected(cognite_node._on_deed_started):
			deed.started.connect(cognite_node._on_deed_started)
			
		if not deed.finalized.is_connected(cognite_node._on_deed_finalized):
			deed.finalized.connect(cognite_node._on_deed_finalized)
			
		if not deed.request.is_connected(cognite_node._on_deed_request):
			deed.request.connect(cognite_node._on_deed_request)
	
	start_cicle()


func start_cicle():
	queue_process_deeds.clear()
	
	if current_process < queue_process_size:
		var deed_id = queue_process_keys[current_process]
		
		if queue_process_group[deed_id] == ProcessMode.CASCADE:
			queue_process_deeds.append(deed_id)
			current_process += 1
		
		else:
			while queue_process_group[deed_id] == ProcessMode.PARALLEL:
				queue_process_deeds.append(deed_id)
				current_process += 1
				
				if current_process >= queue_process_size:
					break
		
		for _deed_id in queue_process_deeds:
			deeds[_deed_id].deed_emit(DeedSignal.STARTED)


func finalized_current_deed(deed_name: StringName):
	var deed_id = deeds_by_name[deed_name]
	
	if queue_process_deeds.has(deed_id):
		deeds[deed_id].deed_emit(DeedSignal.FINALIZED)
		queue_process_deeds.erase(deed_id)
	
	if queue_process_deeds.is_empty():
		start_cicle()


func finish():
	current_process = 0
	
	for deed in deeds:
		deed = deeds[deed] as CogniteRuntimeDeed
		if deed.started.is_connected(cognite_node._on_deed_started):
			deed.started.disconnect(cognite_node._on_deed_started)
			
		if deed.finalized.is_connected(cognite_node._on_deed_finalized):
			deed.finalized.disconnect(cognite_node._on_deed_finalized)
			
		if deed.request.is_connected(cognite_node._on_deed_request):
			deed.request.disconnect(cognite_node._on_deed_request)
