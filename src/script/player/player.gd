extends CharacterBody2D

@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var reload_timer: Timer = $ReloadTimer
@onready var hurt_timer: Timer = $HurtTimer
@onready var weapon_marker: Marker2D = $WeaponPoint/WeaponMarker

@export_category("Movement")
@export var speed := 150
@export var jump_velocity := -300.0
@export var acceleration := 1000
@export var desceleration := 1000

@export_category("Knockback")
@export var knockback_force_x:float = 250.0
@export var knockback_force_y:float = -180.0
@export var knoback_duration:float = 0.2

@export_category("WeaponTest")
@export var weapon_scene:PackedScene


enum PlayerStates {
	IDLE,
	WALK,
	JUMP,
	ATTACK,
	HURT,
	DEATH
}
var current_weapon:Node2D = null
var status:PlayerStates
var facing_right:bool = true
var jump_count : int = 0
const JUMP_COUNT_MAX: int = 2
	
func _ready() -> void:
	go_to_idle_state()
	
	equip_weapon()
	
	var inv = get_tree().get_first_node_in_group("Inventory")
	if inv:
		GameManager.inventory = inv
	
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
	
func equip_weapon() -> void:
	if weapon_scene != null:
		current_weapon = weapon_scene.instantiate()
		weapon_marker.add_child(current_weapon)
		current_weapon.position = Vector2.ZERO
	
func apply_knockback(attacker_position:Vector2) -> void:
	if status == PlayerStates.DEATH:
		return
	var dir_x = sign(global_position.x - attacker_position.x)
	if dir_x == 0:
		dir_x = -1 if facing_right else 1
	velocity = Vector2(dir_x*knockback_force_x, knockback_force_y)
	go_to_hurt_state()
	hurt_timer.start(knoback_duration)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_inventory"):
		var ui = get_tree().get_first_node_in_group("InventoryUI")
		if ui:
			ui.visible = !ui.visible
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func move(delta):
	
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		player_sprite.flip_h = direction < 0
		facing_right = direction > 0
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
	
func walk_state(delta):
	move(delta)
	if velocity.x == 0:
		go_to_idle_state()
		return
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		go_to_jump_state()
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
	
func hurt_state(delta):
	pass
	
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
	
func go_to_death_state():
	status = PlayerStates.DEATH
	player_sprite.play("death")
	velocity.x = 0
	hitbox.set_deferred("monitoring", false)
	reload_timer.start()
	
func go_to_attack_state():
	status = PlayerStates.ATTACK
	player_sprite.play("attack")
	
func hit_enemy(area: Area2D):
	if velocity.y > 0:
		# inimigo morre
		area.get_parent().take_damage()
		go_to_jump_state()
	else:
		# player morre
		if status != PlayerStates.DEATH and status != PlayerStates.HURT:
			apply_knockback(area.global_position)
	
func hit_lethal_area():
	go_to_death_state()
	
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		hit_enemy(area)
	elif area.is_in_group("LethalArea"):
		hit_lethal_area()
	
func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()
	
func _on_hurt_tumer_timeout() -> void:
	if is_on_floor():
		go_to_idle_state()
	else:
		status = PlayerStates.JUMP
		player_sprite.play("jump")
