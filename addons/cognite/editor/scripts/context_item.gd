@tool
extends PanelContainer

const PERCEPTION_CONTEXT_ITEM = preload("res://addons/cognite/editor/perception_context_item.tscn")

var assemble: CogniteAssemble
var context_id: int
var perception_count: int
var context_data: Dictionary
var context_percetion_list: Array[Control]

@onready var context_name: LineEdit = $VBoxContainer/HBoxContainer/context_name
@onready var create_perception_item: MenuButton = $VBoxContainer/PanelContainer/perception_list/PanelContainer/create_perception_item
@onready var perception_list: VBoxContainer = $VBoxContainer/PanelContainer/perception_list
@onready var panel_perception_list: PanelContainer = $VBoxContainer/PanelContainer
@onready var context_activated: CheckButton = $VBoxContainer/header/activated


func _ready() -> void:
	create_perception_item.get_popup().id_pressed.connect(_on_create_perception_item_pressed)


func load_context(_assemble: CogniteAssemble, _context_id: int, _context_data: Dictionary):
	assemble = _assemble; context_id = _context_id; context_data = _context_data
	
	context_name.text = context_data.name
	context_activated.set_pressed_no_signal(context_data.activated)
	
	refresh_itens()
	reset_perception_item_menu()


func refresh_itens():
	for item in context_percetion_list:
		item.queue_free()
	context_percetion_list.clear()
	
	var erase_ids: Array
	for p in context_data.perception_ids:
		var item: Array = assemble.get_perception(p)
		if item.is_empty(): erase_ids.append(p)
		else: create_context_perception_item(p, context_data.perception_ids[p])
	
	for p in erase_ids:
		context_data.perception_ids.erase(p)
	
	assemble.atualize_context(context_id, context_data)
	perception_count = context_data.perception_ids.size()


func create_context_perception_item(perception_id: int, perception: Dictionary):
	var per = PERCEPTION_CONTEXT_ITEM.instantiate()
	perception_list.add_child(per)
	context_percetion_list.append(per)
	per.load_perception(perception_id, perception, context_id, assemble)


func _on_context_name_text_changed(new_text: String) -> void:
	var caret_position = context_name.caret_column
	var word := Cognite.filter_string(new_text, "[A-Za-z_]")
	context_name.set_text(word)
	context_name.caret_column = caret_position
	
	context_data.name = word
	assemble.atualize_context(context_id, context_data)


func _on_activated_toggled(toggled_on: bool) -> void:
	context_data.activated = toggled_on
	assemble.atualize_context(context_id, context_data)


func _on_delete_pressed() -> void:
	assemble.contexts.erase(context_id)
	assemble.actualize.call_deferred()
	queue_free()


func _on_create_perception_item_pressed(id: int) -> void:
	context_data.perception_ids[id] = assemble.PERCEPTION_CONTEXT_TEMPLATE.duplicate(true)
	create_context_perception_item(id, context_data.perception_ids[id])
	assemble.atualize_context(context_id, context_data)
	perception_count = context_data.perception_ids.size()


func _on_show_perception_list_toggled(toggled_on: bool) -> void:
	panel_perception_list.set_visible(toggled_on)


func _on_create_perception_item_about_to_popup() -> void:
	reset_perception_item_menu()


func reset_perception_item_menu():
	create_perception_item.get_popup().clear()
	create_perception_item.get_popup().add_item("Perception", 0)
	create_perception_item.get_popup().set_item_as_separator(0, true)
	create_perception_item.get_popup().set_item_disabled(0, true)
	
	for perception_id in assemble.perceptions:
		var perception: Array = assemble.perceptions[perception_id]
		create_perception_item.get_popup().add_item(perception[0], perception_id)
