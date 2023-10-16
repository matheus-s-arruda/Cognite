@tool
class_name CogniteSource extends Resource


@export_group("Events")
## Events that will trigger changes in states
@export var triggers: Array[String]
## Tests that will trigger actions based on the result
@export var conditions: Array[String]
## Float values that will be tested to trigger actions
@export var ranges: Array[String]
@export_group("Modus")
## Finite states in which the NPC can be, there is no need to assign DEFAULT
@export var states: Array[String]


func is_cognite_source():
	return true



