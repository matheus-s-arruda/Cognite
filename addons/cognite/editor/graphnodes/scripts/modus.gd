@tool
extends CogniteGraphNode


@onready var option_button: OptionButton = $states


func _gui_input(event: InputEvent):
	if event is InputEventMouseMotion:
		return
	
	assemble.nodes[id]["state"] = option_button.selected
	get_options("state")
	option_button.selected = assemble.nodes[id].state
	assemble.actualize()
	super(event)


func get_options(value: String):
	option_button.clear()
	option_button.add_item(value, 0)
	option_button.set_item_disabled(0, true)
	
	var count := 1
	if assemble.source:
		for item in assemble.source.states:
			option_button.add_item(item, count)
			count += 1


func set_data(data: Dictionary):
	if not is_ready:
		await ready
	
	if data.has("position"):
		position_offset = data.position
	
	get_options("state")
	option_button.selected = data.state


