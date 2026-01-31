@tool
class_name CogniteRuntimeDeed extends Node

signal started(_deed_name: StringName)
signal finalized(_deed_name: StringName)
signal request(_deed_name: StringName)

var deed_name: StringName

func _init(_deed_name: String) -> void:
	deed_name = _deed_name


func deed_emit(_signal:int):
	if   not  _signal: started.emit(  deed_name)
	elif _signal == 1: finalized.emit(deed_name)
	elif _signal == 2: request.emit(  deed_name)
