@tool
class_name CogniteFormatSaver extends ResourceFormatSaver


func _get_recognized_extensions(resource) -> PackedStringArray:
	return ["cognite"]


func _recognize(resource: Resource) -> bool:
	return resource is CogniteAssemble


func _save(resource: Resource, path: String = '', flags: int = 0):
	var file := FileAccess.open(path, FileAccess.WRITE)
	var result := var_to_str(inst_to_dict(resource))
	file.store_string(result)

