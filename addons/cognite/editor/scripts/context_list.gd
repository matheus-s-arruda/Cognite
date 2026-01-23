@tool
extends PanelContainer

const CONTEXT_ITEM = preload("uid://dgg6fxmx7asyf")


var current_assemble: CogniteAssemble
var context_map: Dictionary = {}
var context_list: Array[Control]

@onready var node_list: VBoxContainer = $VBoxContainer/PanelContainer/VBoxContainer


func _on_create_perception_item_pressed() -> void:
	var new_context := current_assemble.create_context()
	create_context_item(new_context[0], new_context[1])


func set_assemble(assemble: CogniteAssemble):
	current_assemble = assemble
	refresh_registry()
	
	for context in assemble.contexts:
		create_context_item(context, assemble.contexts[context])


func refresh_registry():
	context_map.clear()
	for button in context_list:
		button.queue_free()
	context_list.clear()


func create_context_item(context_id: int, context: Dictionary):
	var ctx = CONTEXT_ITEM.instantiate()
	node_list.add_child(ctx)
	context_list.append(ctx)
	ctx.load_context(current_assemble, context_id, context)



func load_context_itens():
	var count := 0
	for item in context_map:
		var context_item: Control = CONTEXT_ITEM.instantiate()
		node_list.add_child(context_item)
		count += 1
