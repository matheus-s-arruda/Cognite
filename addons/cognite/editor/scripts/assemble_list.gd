@tool
extends PanelContainer

const ASSEMBLE_LIST_BUTTON = preload("res://addons/cognite/editor/assemble_list_button.tscn")

var assemble_button_group := ButtonGroup.new()

var assemble_map: Dictionary = {}
var assemble_list: Array[Button]

@onready var button_node_list: VBoxContainer = $VBoxContainer/PanelContainer/ScrollContainer/VBoxContainer
@onready var cognite_dock: CogniteDock = $"../.."


func _ready() -> void:
	_connect_filesystem()


func refresh_registry():
	assemble_map.clear()
	for button in assemble_list:
		button.queue_free()
	assemble_list.clear()
	_scan_directory("res://")
	load_assemble_buttons()


func _scan_directory(path: String):
	var dir = DirAccess.open(path)
	if not dir: return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		var full_path = path + file_name
		
		if dir.current_is_dir():
			if not file_name.begins_with("."):
				_scan_directory(full_path + "/")
		elif file_name.ends_with(".tres"):
			if _check_if_cognite_assemble(full_path):
				_add_to_registry(full_path)
		
		file_name = dir.get_next()


func _check_if_cognite_assemble(path: String) -> bool:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file: return false
	var first_line = file.get_line()
	file.close()
	
	return 'script_class="CogniteAssemble"' in first_line


func _get_custom_class_name(path: String) -> String:
	var config = ConfigFile.new()
	var err = config.load(path)
	if err == OK:
		return config.get_value("", "script_class", "")
	return ""


func _add_to_registry(path: String):
	var uid = ResourceLoader.get_resource_uid(path)
	if uid != -1:
		var uid_str = ResourceUID.id_to_text(uid)
		var file_name = path.get_file().get_basename()
		assemble_map[file_name] = uid_str


func _connect_filesystem():
	var fs := EditorInterface.get_resource_filesystem()
	if not fs.filesystem_changed.is_connected(_on_fs_changed):
		fs.filesystem_changed.connect(_on_fs_changed)


func _on_fs_changed():
	refresh_registry()


func load_assemble_buttons():
	var count := 0
	for item in assemble_map:
		var button: Button = ASSEMBLE_LIST_BUTTON.instantiate()
		button_node_list.add_child(button)
		assemble_list.append(button)
		button.pressed.connect(_assemble_button_pressed.bind(assemble_map[item]) )
		button.button_group = assemble_button_group
		button.text = item
		count += 1


func _assemble_button_pressed(uid: String):
	var assemble = load(uid)
	if assemble:
		cognite_dock.set_current_assemble(assemble)
