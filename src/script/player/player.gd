extends CharacterBody2D

@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var reload_timer: Timer = $ReloadTimer
@onready var hurt_timer: Timer = $HurtTimer
@onready var weapon_marker: Marker2D = $WeaponMarker

@export_category("Combat")
@export var invuln_duration:float = 0.6
@export var hurt_control_factor:float = 0.4  # 0 = sem controle, 1 = controle total


@export_category("Movement")
@export var speed := 150
@export var jump_velocity := -300.0
@export var acceleration := 1000
@export var desceleration := 1000

@export_category("Knockback")
@export var knockback_force_x:float = 250.0
@export var knockback_force_y:float = -180.0
@export var knoback_duration:float = 0.2

enum PlayerStates {
	IDLE,
	WALK,
	JUMP,
	ATTACK,
	HURT,
	DEATH
}

var status:PlayerStates
var facing_right:bool = true
var jump_count:int = 0
const JUMP_COUNT_MAX:int = 2
var is_invulnerable:bool = false

var current_weapon = null
const WEAPON_SCENE = preload("res://entities/weapons/weapon.tscn")

func _ready() -> void:
	go_to_idle_state()
	
	var inv = get_tree().get_first_node_in_group("Inventory")
	if inv:
		GameManager.inventory = inv
	_setup()
	
func _physics_process(delta: float) -> void:
		
	#Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match status:
		PlayerStates.IDLE:
			idle_state(delta)
		PlayerStates.WALK:
			walk_state(delta)
		PlayerStates.JUMP:
			jump_state(delta)
		PlayerStates.ATTACK:
			attack_state(delta)
		PlayerStates.HURT:
			hurt_state(delta)
		PlayerStates.DEATH:
			death_state(delta)
			
	move_and_slide()
	
func _setup() -> void:
	current_weapon = WEAPON_SCENE.instantiate()
	weapon_marker.add_child(current_weapon) # Adiciona a arma atual como um nó filho do WeaponMarker
	if GameManager.selected_weapon:
		current_weapon.config(GameManager.selected_weapon)
	current_weapon.attack_finished.connect(_on_weapon_attack_finished)
	
	var test_weapon:WeaponResource = preload("res://itens/weapons/iron_sword.tres")
	current_weapon.config(test_weapon)
	_update_weapon_side()
	
func _on_weapon_attack_finished() -> void:
	if status == PlayerStates.ATTACK:
		go_to_idle_state()
	
func _update_weapon_side() -> void:
	var dir = 1 if facing_right else -1
	weapon_marker.position.x = abs(weapon_marker.position.x) * dir
	if current_weapon:
		current_weapon.set_side(dir)
	
func apply_knockback(attacker_position:Vector2) -> void:
	if status == PlayerStates.DEATH:
		return
	var dir_x = sign(global_position.x - attacker_position.x)
	if dir_x == 0:
		dir_x = -1 if facing_right else 1
	velocity = Vector2(dir_x * knockback_force_x, knockback_force_y)
	go_to_hurt_state()
	hurt_timer.start(knoback_duration)
	_start_invulnerability()
	
func _start_invulnerability() -> void:
	is_invulnerable = true
	await get_tree().create_timer(invuln_duration).timeout
	is_invulnerable = false
	
func move(delta):
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		player_sprite.flip_h = direction < 0
		facing_right = direction > 0
		_update_weapon_side()
	else:
		velocity.x = move_toward(velocity.x, 0, desceleration * delta)
	
func idle_state(delta):
	move(delta)
	if velocity.x !=0:
		go_to_walk_state()
		return
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		go_to_jump_state()
		return
		
	if Input.is_action_just_pressed("attack") and current_weapon and current_weapon.can_attack:
		go_to_attack_state()
		var dir = 1 if facing_right else -1
		current_weapon.attack(dir)
		return
	
func walk_state(delta):
	move(delta)
	if velocity.x == 0:
		go_to_idle_state()
		return
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		go_to_jump_state()
		return
		
	if Input.is_action_just_pressed("attack") and current_weapon and current_weapon.can_attack:
		go_to_attack_state()
		var dir = 1 if facing_right else -1
		current_weapon.attack(dir)
		return
	
func jump_state(delta):
	move(delta)
	
	# Sistema de Pulo Duplo
	if Input.is_action_just_pressed("jump") and jump_count < JUMP_COUNT_MAX:
		go_to_jump_state()
		
	if is_on_floor():
		jump_count = 0 # Resetar o contador de jump ao encostar no chão
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return
		
	if Input.is_action_just_pressed("attack") and current_weapon and current_weapon.can_attack:
		go_to_attack_state()
		var dir = 1 if facing_right else -1
		current_weapon.attack(dir)
		return
	
func hurt_state(delta):
	move(delta)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		go_to_jump_state()
	
func death_state(_delta):
	pass
	
func attack_state(delta):
	move(delta)
	
func go_to_idle_state():
	status = PlayerStates.IDLE
	player_sprite.play("idle")
	
func go_to_walk_state():
	status = PlayerStates.WALK
	player_sprite.play("walk")
	
func go_to_jump_state():
	status = PlayerStates.JUMP
	player_sprite.play("jump")
	velocity.y = jump_velocity
	jump_count+=1 # Contador de pulos
	
func go_to_hurt_state():
	status = PlayerStates.HURT
	player_sprite.play("idle")
	
func go_to_death_state():
	status = PlayerStates.DEATH
	player_sprite.play("death")
	velocity.x = 0
	hitbox.set_deferred("monitoring", false)
	reload_timer.start()
	
func go_to_attack_state():
	status = PlayerStates.ATTACK
	# player_sprite.play("attack")
	
func hit_enemy(area: Area2D):
	if velocity.y > 0:
		area.get_parent().take_damage(1)  # dano fixo do jump-attack, ou crie uma constante
		go_to_jump_state()
	elif not is_invulnerable and status != PlayerStates.DEATH:
		apply_knockback(area.global_position)
	
func hit_lethal_area():
	go_to_death_state()
	
func hit_projectile(area):
	if status == PlayerStates.DEATH:
		return
	var dmg = area.damage if "damage" in area else 1
	area.queue_free()
	if is_invulnerable:
		return
	GameManager.take_damage(dmg)
	apply_knockback(area.global_position)
	
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		hit_enemy(area)
	elif area.is_in_group("EnemyProjectile"):
		hit_projectile(area)
	elif area.is_in_group("LethalArea"):
		hit_lethal_area()
	
func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()
	
func _on_hurt_timer_timeout() -> void:
	if is_on_floor():
		go_to_idle_state()
	else:
		status = PlayerStates.JUMP
		player_sprite.play("jump")
