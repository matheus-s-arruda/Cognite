@tool
extends PanelContainer

const DECISION_CONTEXT_ITEM = preload("res://addons/cognite/editor/decision_context_item.tscn")

var id: int
var decision_data: Dictionary
var assemble: CogniteAssemble

var decision_map: Dictionary = {}
var context_list: Array[Control]

@onready var decision_name: LineEdit = $VBoxContainer/HBoxContainer/decision_name
@onready var score_value: LineEdit = $VBoxContainer/HBoxContainer3/score_value
@onready var create_context_item: MenuButton = $VBoxContainer/PanelContainer/VBoxContainer/create_context_item
@onready var context_itens: VBoxContainer = $VBoxContainer/PanelContainer/VBoxContainer
@onready var decision_buttons: PanelContainer = $VBoxContainer/PanelContainer


func _ready() -> void:
	create_context_item.get_popup().id_pressed.connect(_on_create_context_item_pressed)


func load_context(current_assemble: CogniteAssemble, decision_id: int, decision: Dictionary):
	assemble = current_assemble; id = decision_id; decision_data = decision
	decision_name.text = decision.name
	score_value.text = str(decision.base_score)
	
	for ctx in decision.context_ids:
		create_decision_context_item(ctx)


func reset_perception_item_menu():
	create_context_item.get_popup().clear()
	create_context_item.get_popup().add_item("Context", 0)
	create_context_item.get_popup().set_item_as_separator(0, true)
	create_context_item.get_popup().set_item_disabled(0, true)
	
	for context_id in assemble.contexts:
		var ctx: Dictionary = assemble.get_context(context_id)
		create_context_item.get_popup().add_item(ctx.name, context_id)


func create_decision_context_item(context_id: int):
	var ctx = DECISION_CONTEXT_ITEM.instantiate()
	context_itens.add_child(ctx)
	context_list.append(ctx)
	ctx.load_context(context_id, id, assemble)


func _on_activated_toggled(toggled_on: bool) -> void:
	decision_data.activated = toggled_on
	assemble.atualize_decision(id, decision_data)


func _on_delete_pressed() -> void:
	assemble.decisions.erase(id)
	assemble.actualize.call_deferred()
	queue_free()


func _on_decision_name_text_changed(new_text: String) -> void:
	var caret_position = decision_name.caret_column
	var word := Cognite.filter_string(new_text, "[A-Za-z_]")
	decision_name.set_text(word)
	decision_name.caret_column = caret_position
	
	decision_data.name = word
	assemble.atualize_decision(id, decision_data)


func _on_score_value_text_changed(new_text: String) -> void:
	var caret_position = score_value.caret_column
	var word := Cognite.filter_string(new_text, "[-0-9]")
	score_value.set_text(word)
	score_value.caret_column = caret_position
	decision_data.base_score = int(word)
	assemble.atualize_decision(id, decision_data)


func _on_create_context_item_pressed(index: int):
	decision_data.context_ids[index] = 0
	create_decision_context_item(index)
	assemble.atualize_decision(id, decision_data)


func _on_create_context_item_about_to_popup() -> void:
	reset_perception_item_menu()


func _on_show_context_list_toggled(toggled_on: bool) -> void:
	decision_buttons.visible = toggled_on
