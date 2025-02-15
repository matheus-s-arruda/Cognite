extends CharacterBody2D

const MAX_SPEED := 100.0
const SUMMON_TIME := 3.0

var distance_to_player: float
var can_summom := false

var direction: Vector2
var motion: Vector2

var player: Node2D

@onready var cognite = $CogniteNode
@onready var animation = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var summon_delay: Timer = $summon_delay


func _physics_process(delta):
	if player:
		distance_to_player = global_position.distance_to(player.global_position)
		
		if cognite.current_state == "ATTACK":
			direction = Vector2.ZERO
			attack()
		
		elif cognite.current_state == "HUNT":
			direction = global_position.direction_to(player.global_position)
		else:
			direction = Vector2.ZERO
	
	if cognite.current_state == "SUMMOM":
		direction = Vector2.ZERO
		summon()
	
	if direction:
		motion = motion.lerp(direction * MAX_SPEED, 0.5)
	else:
		motion = motion.lerp(Vector2.ZERO, 0.2)
	
	animation.flip_h = velocity.x < 0.0
	collision.position.x = 6 if velocity.x < 0.0 else -6
	
	velocity = motion
	move_and_slide()


func attack():
	animation.play("attack")
	animation.animation_finished.connect(func(): cognite.animation_end.emit(), CONNECT_ONE_SHOT)


func summon():
	can_summom = false
	summon_delay.start(SUMMON_TIME)
	
	animation.play("summon")
	animation.animation_finished.connect(func(): cognite.animation_end.emit(), CONNECT_ONE_SHOT)


func skill():
	animation.play("skill")
	animation.animation_finished.connect(func(): cognite.animation_end.emit(), CONNECT_ONE_SHOT)


func _on_detect_player_body_entered(body):
	player = body
	cognite.player_detected.emit()


func _on_summon_delay_timeout() -> void:
	can_summom = true
