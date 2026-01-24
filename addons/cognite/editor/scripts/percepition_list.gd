@tool
extends PanelContainer

const PERCEPTION_ITEM = preload("uid://1r7qeyebm7rx")


@onready var perceptions: VBoxContainer = $VBoxContainer/PanelContainer/VBoxContainer

var assemble: CogniteAssemble
var perceptions_list: Dictionary


func set_assemble(_assemble: CogniteAssemble):
	assemble = _assemble
	reset()
	load_itens()


func reset():
	var chidrens := perceptions.get_child_count()
	for child in chidrens - 1:
		perceptions.get_child(chidrens - child - 1).queue_free()


func load_itens():
	for perception in assemble.perceptions:
		var item = PERCEPTION_ITEM.instantiate()
		perceptions.add_child(item)
		item.Assemble = assemble
		item.assemble_perception_id = perception
		item.load_property(assemble.perceptions[perception])


func create_item():
	var new_perception := assemble.create_perception()
	var item = PERCEPTION_ITEM.instantiate()
	
	perceptions.add_child(item)
	item.Assemble = assemble
	item.load_property(new_perception[1])
	item.assemble_perception_id = new_perception[0]
	


func _on_create_perception_item_pressed() -> void:
	create_item()
