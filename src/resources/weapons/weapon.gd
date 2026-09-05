extends Node2D
class_name Weapon

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var cooldown: Timer = $Cooldown
@onready var melee_hitbox: Area2D = $MeleeHitbox
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal attack_finished

var data:WeaponResource
var can_attack:bool = true
var _pending_direction:int = 1

func _ready() -> void:
	cooldown.timeout.connect(func():
		can_attack = true )
	melee_hitbox.monitoring = false
	melee_hitbox.area_entered.connect(_on_melee_hit)
	animation_player.animation_finished.connect(_on_animation_finished)
	
func config(new_data:WeaponResource) -> void:
	data = new_data
	sprite_2d.texture = data.icon
	cooldown.wait_time = data.fire_rate

func attack(direction:int) -> void:
	if not can_attack or data == null:
		return
	can_attack = false
	cooldown.start()
	_pending_direction = direction
	sprite_2d.scale.x = direction
	data.execute_attack(self, direction)

func do_melee_swing(direction:int , _arc:float) -> void:
	animation_player.play("swing")

func do_ranged_shot(proj_scene:PackedScene, proj_texture:Texture2D, proj_speed:float, direction:int) -> void:
	
	if proj_scene == null: # Verifica se possue uma cena
		push_warning("Arma ranged sem projectile_scene configurada.")
		attack_finished.emit()
		return
	var proj = proj_scene.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.global_position = global_position
	if proj.has_method("set_texture"):
		proj.set_texture(proj_texture)
	proj.set_direction(direction)
	if proj.has_method("set_speed"):
		proj.set_speed(proj_speed)
	attack_finished.emit()

func _activate_hitbox() -> void:
	melee_hitbox.monitoring = true

func _deactivate_hitbox() ->  void:
	melee_hitbox.monitoring = false

func _on_melee_hit(area:Area2D) -> void:
	if area.is_in_group("Enemies") and data:
		area.get_parent().take_damage(data.damage)

func _on_animation_finished(anim_name:StringName) -> void:
	if anim_name == "swing":
		animation_player.play("RESET")
		attack_finished.emit()
