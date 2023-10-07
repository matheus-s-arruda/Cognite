@tool
class_name CogniteFormatLoader extends ResourceFormatLoader



func _get_recognized_extensions() -> PackedStringArray:
	return ["cognite"]

func _get_resource_type(path: String) -> String:
	var ext = path.get_extension().to_lower()
	if ext == "cognite":
		return "Resource"
	return ""


func _handles_type(typename: StringName) -> bool:
	return ClassDB.is_parent_class(typename, "Resource")


func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int):
	if ResourceLoader.exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		return dict_to_inst(str_to_var(file.get_as_text()))
	else:
		push_error("File does not exists")
		return false


func _get_dependencies(path:String, add_type:bool):
	var depends_on : PackedStringArray
	var assemble: CogniteAssemble = load(path)
	
	if assemble.source:
		depends_on.append(assemble.source.resource_path)
	
	return depends_on


func _rename_dependencies(path: String, renames: Dictionary):
	var assemble: CogniteAssemble = load(path)
	if assemble.source and assemble.source.resource_path in renames:
		assemble.source.resource_path = renames[assemble.source.resource_path]
	
	ResourceSaver.save(assemble, path)
	return OK
