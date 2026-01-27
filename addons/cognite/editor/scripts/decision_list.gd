@tool
extends PanelContainer

const DECISION_ITEM = preload("res://addons/cognite/editor/decision_item.tscn")

var current_assemble: CogniteAssemble
var decision_list: Array[Control]

@onready var context_list: VBoxContainer = $VBoxContainer/PanelContainer/ScrollContainer/VBoxContainer


func set_assemble(assemble: CogniteAssemble):
	current_assemble = assemble
	refresh_registry()
	
	for decision in assemble.decisions:
		create_decision_item(decision, assemble.decisions[decision])


func refresh_registry():
	for button in decision_list:
		button.queue_free()
	decision_list.clear()


func create_decision_item(decision_id: int, decision: Dictionary):
	var ctx = DECISION_ITEM.instantiate()
	context_list.add_child(ctx)
	decision_list.append(ctx)
	ctx.load_context(current_assemble, decision_id, decision)


func _on_create_decision_item_pressed() -> void:
	var new_decision := current_assemble.create_decision()
	create_decision_item(new_decision[0], new_decision[1])
