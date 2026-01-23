@tool
extends PanelContainer

const PERCEPTION_CONTEXT_ITEM = preload("uid://dm7ya0ai3sps4")

var assemble: CogniteAssemble
var context_id: int

var context_percetion_list: Array[Control]

@onready var context_name: LineEdit = $VBoxContainer/HBoxContainer/context_name
@onready var min_shot: LineEdit = $VBoxContainer/HBoxContainer2/min_shot
@onready var create_perception_item: MenuButton = $VBoxContainer/create_perception_item
@onready var perception_list: VBoxContainer = $VBoxContainer


func load_context(_assemble: CogniteAssemble, _context_id: int):
	assemble = _assemble; context_id = _context_id
	var context: Dictionary = assemble.contexts[context_id]
	context_name.text = context.name
	min_shot.text = context.min_shot


func refresh_itens():
	for item in context_percetion_list:
		item.queue_free()
	context_percetion_list.clear()


func create_context_perception_item():
	var per = PERCEPTION_CONTEXT_ITEM.instantiate()
	perception_list.add_child(per)
	


func _on_delete_pressed() -> void:
	pass # Replace with function body.


func _on_create_perception_item_pressed() -> void:
	pass # Replace with function body.
