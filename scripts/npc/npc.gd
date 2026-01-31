extends CharacterBody2D

enum States {IDLE, MOVING, ATTACK, SUMMON}

const MAX_SPEED := 100.0
const SUMMON_TIME := 3.0

var current_state: int

var can_summom := false
var direction: Vector2
var motion: Vector2

@onready var player: CharacterBody2D = $"../player"
@onready var cognite_node: CogniteNode = $CogniteNode
@onready var animation = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var summon_delay: Timer = $summon_delay


func _physics_process(delta):
	#if not cognite_node.current_decision: return
	#
	#if cognite_node.current_decision.name == "Atacar":
		#current_state = States.MOVING
	#
	#if cognite_node.current_decision.name == "Summonar":
		#current_state = States.SUMMON
		
	#
	#match current_state:
		#States.IDLE:
			#pass
		#
		#States.MOVING:
			#move()
		#
		#States.ATTACK:
			#attack()
		#
		#States.SUMMON:
			#if can_summom: summon()
			#if animation.animation != "summon":
				#move()
			
	
	if direction:
		motion = motion.lerp(direction * MAX_SPEED, 0.5)
	
	else: motion = motion.lerp(Vector2.ZERO, 0.2)
	velocity = motion
	move_and_slide()


func move(to: Vector2):
	direction = position.direction_to(to)
	motion = motion.lerp(direction * MAX_SPEED, 0.5)
	
	animation.flip_h = velocity.x < 0.0
	collision.position.x = 6 if velocity.x < 0.0 else -6


func attack():
	animation.play("attack")


func summon():
	can_summom = false
	summon_delay.start(SUMMON_TIME)
	animation.play("summon")


func skill():
	animation.play("skill")


func _on_summon_delay_timeout() -> void:
	can_summom = true


func _on_cognite_node_started(_deed_name: StringName) -> void:
	if _deed_name == "StopMotion":
		move(position)
		
	if _deed_name == "PickRandomPoint":
		move(player.position)


func _on_cognite_node_finalized(_deed_name: StringName) -> void:
	pass # Replace with function body.
