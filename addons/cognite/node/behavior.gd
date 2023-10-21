@tool
class_name CogniteBehavior extends Resource
## use this class to inject behavior code into a CogniteAssemble.

## Node that will be observed, this node must contain the methods and properties that CogniteBehavior will access
var root: Node

## The code inside this function will be called whenever the state is activated.
func start():
	pass

## Called in every frame relative to [code]Node._process(delta)[/code].
func process(delta: float):
	pass

## Called in every frame relative to [code]Node._physics_process(delta)[/code].
func physics_process(delta: float):
	pass
