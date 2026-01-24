@tool
extends PanelContainer

const PERCEPTION_CONTEXT_ITEM = preload("uid://dm7ya0ai3sps4")

var assemble: CogniteAssemble
var context_id: int
var perception_count: int
var context_data: Dictionary
var context_percetion_list: Array[Control]

@onready var context_name: LineEdit = $VBoxContainer/HBoxContainer/context_name
@onready var min_shot: LineEdit = $VBoxContainer/HBoxContainer2/min_shot
@onready var max_shot: LineEdit = $VBoxContainer/HBoxContainer2/max_shot
@onready var create_perception_item: MenuButton = $VBoxContainer/PanelContainer/perception_list/PanelContainer/create_perception_item
@onready var perception_list: VBoxContainer = $VBoxContainer/PanelContainer/perception_list
@onready var panel_perception_list: PanelContainer = $VBoxContainer/PanelContainer
@onready var context_activated: CheckButton = $VBoxContainer/header/activated
@onready var priority_value: LineEdit = $VBoxContainer/HBoxContainer3/priority_value


func _ready() -> void:
	create_perception_item.get_popup().id_pressed.connect(_on_create_perception_item_pressed)


func load_context(_assemble: CogniteAssemble, _context_id: int, _context_data: Dictionary):
	assemble = _assemble; context_id = _context_id; context_data = _context_data
	
	context_name.text = context_data.name
	min_shot.text = str(context_data.min_shot)
	priority_value.text = str(context_data.priority)
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
		if item.is_empty():
			erase_ids.append(p)
		else:
			create_context_perception_item(p, context_data.perception_ids[p])
	
	for p in erase_ids:
		context_data.perception_ids.erase(p)
	
	assemble.atualize_context(context_id, context_data)
	perception_count = context_data.perception_ids.size()
	max_shot.text = "/" + str(perception_count)


func create_context_perception_item(perception_id: int, data: Dictionary):
	var per = PERCEPTION_CONTEXT_ITEM.instantiate()
	perception_list.add_child(per)
	context_percetion_list.append(per)
	per.load_perception(perception_id, context_id, data, assemble)


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


func _on_min_shot_text_changed(new_text: String) -> void:
	var caret_position = min_shot.caret_column
	var word := Cognite.filter_string(new_text, "[0-9]")
	var inter := int(word)
	inter = min(inter, perception_count)
	
	min_shot.set_text(str(inter))
	min_shot.caret_column = caret_position
	
	context_data.min_shot = inter
	assemble.atualize_context(context_id, context_data)


func _on_delete_pressed() -> void:
	assemble.contexts.erase(context_id)
	assemble.actualize.call_deferred()
	queue_free()


func _on_create_perception_item_pressed(id: int) -> void:
	var p := {"min": null, "max": null, "boolean": false}
	context_data.perception_ids[id] = p
	create_context_perception_item(id, p)
	assemble.atualize_context(context_id, context_data)
	perception_count = context_data.perception_ids.size()
	max_shot.text = "/" + str(perception_count)


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


func _on_priority_value_text_changed(new_text: String) -> void:
	var caret_position = priority_value.caret_column
	var word := Cognite.filter_string(new_text, "[0-9]")
	priority_value.set_text(word)
	priority_value.caret_column = caret_position
	
	context_data.priority = int(word)
	assemble.atualize_context(context_id, context_data)
