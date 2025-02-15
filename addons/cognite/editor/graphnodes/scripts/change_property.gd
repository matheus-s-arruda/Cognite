@tool
extends CogniteGraphNode

@onready var option_button: OptionButton = $OptionButton
@onready var line_edit: LineEdit = $LineEdit
@onready var range = $HBoxContainer/range
@onready var check_button = $HBoxContainer2/CheckButton
@onready var h_box_container = $HBoxContainer
@onready var h_box_container_2 = $HBoxContainer2


func _input(event: InputEvent):
	if event is InputEventMouseMotion: return
	
	assemble.nodes[id]["range"] = range.value
	assemble.nodes[id]["properties"] = option_button.selected
	assemble.nodes[id]["condition"] = check_button.button_pressed
	
	super(event)


func set_data(data: Dictionary):
	if not is_ready:
		await ready
	
	if data.has("position"): position_offset = data.position
	if data.has("range"): range.value = data.range
	if data.has("property"): line_edit.set_text(data.property)
	if data.has("condition"): check_button.set_pressed_no_signal(data.condition)
	if data.has("properties"): option_button.selected = data.properties
	
	h_box_container_2.visible = option_button.selected == 0
	h_box_container.visible = option_button.selected == 1


func _on_line_edit_text_changed(new_text: String) -> void:
	var caret_position = line_edit.caret_column
	var word := _filter_string(new_text)
	line_edit.set_text(word)
	
	line_edit.caret_column = caret_position
	assemble.nodes[id]["property"] = word
	assemble.actualize()


func _on_option_button_item_selected(index: int) -> void:
	h_box_container_2.visible = index == 0
	h_box_container.visible = index == 1
