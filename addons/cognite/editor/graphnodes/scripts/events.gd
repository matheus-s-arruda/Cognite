@tool
extends CogniteGraphNode


@onready var option_button: OptionButton = $OptionButton



func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		return
	
	assemble.nodes[id]["trigger"] = option_button.selected
	get_options()
	option_button.selected = assemble.nodes[id].trigger


func _gui_input(event: InputEvent):
	if event is InputEventMouseMotion:
		return
	
	assemble.actualize()
	super(event)


func get_options():
	option_button.clear()
	option_button.add_item("Trigger", 0)
	option_button.set_item_disabled(0, true)
	
	var count := 1
	if assemble.source:
		for item in assemble.source.triggers:
			option_button.add_item(item, count)
			count += 1


func set_data(data: Dictionary):
	if not is_ready:
		await ready
	
	if data.has("position"):
		position_offset = data.position
	
	get_options()
	option_button.select(data.trigger)
