@tool
class_name CogniteAssemble extends Resource

signal actualized

@export var nodes: Dictionary

#[
#	0: ["distance", TYPE_FLOAT
#]
@export var perceptions: Array[Array]


func is_cognite_assemble():
	return true


func actualize():
	save()
	actualized.emit()


func save():
	take_over_path(resource_path)
	ResourceSaver.save(self, resource_path)
