@tool
class_name CogniteNode extends Node

var updating: bool


@export var perception_target: NodePath

@export var cognite_assemble: CogniteAssemble:
	set(value):
		cognite_assemble = value
		#Cognite.create.emit()


func _ready():
	if Engine.is_editor_hint():
		return


func is_cognite_node():
	return true
