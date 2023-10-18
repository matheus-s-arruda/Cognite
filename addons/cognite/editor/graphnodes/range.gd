@tool
extends CogniteGraphNode


@onready var option_button = $OptionButton
@onready var bigger = $HBoxContainer2/bigger
@onready var smaller = $HBoxContainer/smaller


func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		return
	
	assemble.nodes[id]["range"] = option_button.selected
	
	get_options()
	option_button.selected = assemble.nodes[id].range


func get_options():
	option_button.clear()
	option_button.add_item("Range", 0)
	option_button.set_item_disabled(0, true)
	
	var count := 1
	if assemble.source:
		for item in assemble.source.ranges:
			option_button.add_item(item, count)
			count += 1


func set_data(data: Dictionary):
	if not is_ready:
		await ready
	
	if data.has("position"):
		position_offset = data.position
	
	get_options()
	option_button.selected = data.range
	
	if assemble.nodes[id].has("bigger"):
		bigger.value = data.bigger
	else:
		assemble.nodes[id]["bigger"] = 1.0
	
	if assemble.nodes[id].has("smaller"):
		smaller.value = data.smaller
	else:
		assemble.nodes[id]["smaller"] = 0.0


func _on_bigger_value_changed(value):
	assemble.nodes[id]["bigger"] = value

func _on_smaller_value_changed(value):
	assemble.nodes[id]["smaller"] = value
