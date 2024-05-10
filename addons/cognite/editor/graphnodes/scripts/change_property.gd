@tool
extends CogniteGraphNode

@onready var option_button: OptionButton = $OptionButton
@onready var option_button_2 = $OptionButton2
@onready var range = $HBoxContainer/range
@onready var check_button = $HBoxContainer2/CheckButton
@onready var h_box_container = $HBoxContainer
@onready var h_box_container_2 = $HBoxContainer2


func _input(event: InputEvent):
	if event is InputEventMouseMotion: return
	
	assemble.nodes[id]["range"] = range.value
	assemble.nodes[id]["property"] = option_button_2.selected
	assemble.nodes[id]["properties"] = option_button.selected
	assemble.nodes[id]["condition"] = check_button.button_pressed
	
	get_options()
	range.value = assemble.nodes[id].range
	option_button.selected = assemble.nodes[id].properties
	option_button_2.selected = assemble.nodes[id].property
	check_button.set_pressed_no_signal(assemble.nodes[id].condition)
	super(event)


func _gui_input(event: InputEvent):
	if event is InputEventMouseMotion: return
	
	assemble.actualize()
	super(event)


func get_options():
	option_button_2.clear()
	option_button_2.add_item("Condition" if option_button.selected == 0 else "Range", 0)
	option_button_2.set_item_disabled(0, true)
	
	var count := 1
	if assemble.source:
		var array = assemble.source.conditions if option_button.selected == 0 else assemble.source.ranges
		for item in array:
			option_button_2.add_item(item, count)
			count += 1
	
	set_size(Vector2.ZERO)


func set_data(data: Dictionary):
	if not is_ready:
		await ready
	
	if data.has("position"):
		position_offset = data.position
	
	get_options()
	if data.has("range"): range.value = data.range
	if data.has("properties"): option_button.selected = data.properties
	if data.has("property"): option_button_2.selected = data.property
	if data.has("condition"): check_button.set_pressed_no_signal(data.condition)
	
	h_box_container_2.visible = option_button.selected == 0
	h_box_container.visible = option_button.selected == 1


func _on_option_button_item_selected(index):
	get_options();
	assemble.nodes[id]["properties"] = option_button.selected
	h_box_container_2.visible = index == 0
	h_box_container.visible = index == 1
	
	
