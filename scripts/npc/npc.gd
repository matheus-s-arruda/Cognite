extends CharacterBody2D


@onready var cognite_node = $CogniteNode


func _ready():
	pass


func _input(event):
	if Input.is_action_just_pressed("ui_down"):
		cognite_node.vendeu = !cognite_node.vendeu
