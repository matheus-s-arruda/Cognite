@tool
extends CogniteGraphNode


@onready var option_button: OptionButton = $states
@onready var button = $HBoxContainer/Button
@onready var button_2 = $HBoxContainer/Button2


func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		return
	
	assemble.nodes[id]["state"] = option_button.selected
	get_options("state")
	option_button.selected = assemble.nodes[id].state


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
	
	if data.has("assembly"):
		button.text = assemble.nodes[id].assembly
		button_2.visible = true
	
	get_options("state")
	option_button.selected = data.state


var fileDialog : EditorFileDialog

func _on_button_pressed():
	if assemble.nodes[id].has("assembly"):
		EditorInterface.inspect_object(load(assemble.nodes[id].assembly))
		return
	
	fileDialog = EditorFileDialog.new()
	fileDialog.mode = Window.MODE_MAXIMIZED
	#fileDialog.set_filters(PackedStringArray(["*.cognite"]))
	fileDialog.access = EditorFileDialog.ACCESS_RESOURCES
	fileDialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	fileDialog.file_selected.connect(set_assembly_path)
	
	get_tree().root.add_child(fileDialog)
	fileDialog.popup()


func set_assembly_path(path: String):
	fileDialog.queue_free.call_deferred()
	assemble.nodes[id]["assembly"] = path
	button_2.visible = true
	button.text = path


func _on_button_2_pressed():
	if assemble.nodes[id].has("assembly"):
		assemble.nodes[id].erase("assembly")
		button.text = "[empty]"
		button_2.visible = false
