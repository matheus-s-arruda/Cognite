extends CharacterBody2D

const MAX_SPEED := 100.0


var target_position: Vector2
var direction: Vector2
var motion: Vector2

var player: Node

@onready var cognite = $CogniteNode
@onready var animation = $AnimatedSprite2D
@onready var collision = $CollisionShape2D


func _ready():
	target_position = global_position


func _physics_process(delta):
	if global_position.distance_to(target_position) > 10.0:
		direction = global_position.direction_to(target_position)
	else:
		direction = Vector2.ZERO
	
	if direction:
		motion = motion.lerp(direction * MAX_SPEED, 0.5)
	else:
		motion = motion.lerp(Vector2.ZERO, 0.2)
	
	animation.flip_h = velocity.x < 0.0
	collision.position.x = 6 if velocity.x < 0.0 else -6
	
	velocity = motion
	move_and_slide()
	
	if player:
		cognite.distance_to_player = global_position.distance_to(player.global_position)
		
		if cognite.delay_summon > 0.0:
			cognite.delay_summon -= delta
	
	match cognite.propertie_names.state[cognite.current_state]:
		"ATTACK": attack()
		"SUMMON": summon()
		"SKILL": skill()
	

func attack():
	target_position = global_position
	animation.play("attack")
	animation.animation_finished.connect(func(): cognite.attacking = false, CONNECT_ONE_SHOT)


func summon():
	target_position = global_position
	animation.play("summon")
	animation.animation_finished.connect(func(): cognite.summoning = false, CONNECT_ONE_SHOT)


func skill():
	target_position = global_position
	animation.play("skill")
	animation.animation_finished.connect(func(): cognite.using_skill = false, CONNECT_ONE_SHOT)


func _on_detect_player_body_entered(body):
	player = body
	cognite.player_detected.emit()
	cognite.is_hunt = true
