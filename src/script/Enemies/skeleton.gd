extends CharacterBody2D

@onready var skeleton_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detect: RayCast2D = $CollosionDetect/WallDetect
@onready var ground_detect: RayCast2D = $CollosionDetect/GroundDetect
@onready var player_detect: RayCast2D = $CollosionDetect/PlayerDetect
@onready var bone_start_position: Node2D = $BoneStartPosition
@onready var timer_death: Timer = $TimerDeath

const BONE_THROW = preload("uid://5eflorsejici")

@export var Damage:int = 1

const SPEED:float = 30.0
const JUMP_VELOCITY:float = -400.0
const MAX_HEALTH:int = 10

var direction:int = 1
var can_throw:bool = true
var health:int = MAX_HEALTH

enum SkeletonStates {
	WALK,
	DEATH,
	ATTACK
}

var status : SkeletonStates

func _ready() -> void:
	go_to_walk_state()
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		SkeletonStates.WALK:
			walk_state(delta)
		SkeletonStates.DEATH:
			death_state(delta)
		SkeletonStates.ATTACK:
			attack_state(delta)
			
	move_and_slide()
	
func walk_state(_delta):
	if is_on_floor():
		go_to_walk_state()
		velocity.x = SPEED * direction
	
	if wall_detect.is_colliding():
		direction *= -1 # Multiplicar por -1 inverte o sinal
		scale.x *= -1
		return
		
	if not ground_detect.is_colliding():
		direction *= -1 # Multiplicar por -1 inverte o sinal
		scale.x *= -1
		return
	
	if player_detect.is_colliding():
		go_to_attack_state()
		return
	
func attack_state(_delta):
	if skeleton_sprite.frame == 2 and can_throw:
		throw_bone()
		can_throw = false
	
func death_state(_delta):
	pass
	
func go_to_walk_state():
	status = SkeletonStates.WALK
	skeleton_sprite.play("walk")
	
func go_to_attack_state():
	status = SkeletonStates.ATTACK
	skeleton_sprite.play("attack")
	velocity = Vector2.ZERO
	can_throw = true
	
func go_to_death_state():
	status = SkeletonStates.DEATH
	skeleton_sprite.play("death")
	# Desativar hitbox ao morrer
	#hitbox.queue_free()
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO
	timer_death.start()
	
func take_damage(amount: int = 1) -> void:
	health -= amount
	if health <= 0:
		go_to_death_state()
	
func throw_bone():
	var new_bone = BONE_THROW.instantiate()
	add_sibling(new_bone)
	new_bone.position = bone_start_position.global_position
	new_bone.set_direction(self.direction)
	
func _on_animated_attack_animation_finished() -> void:
	if skeleton_sprite.animation == "attack":
		go_to_walk_state()
		return
	
func _on_timer_death_timeout() -> void:
	skeleton_sprite.queue_free()
