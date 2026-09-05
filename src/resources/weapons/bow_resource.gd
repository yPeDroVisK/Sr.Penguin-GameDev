extends WeaponResource
class_name BowResource

@export var projectile_scene:PackedScene
@export var projectile_speed:float = 200.0
@export var sprite_projectile:Texture2D

func execute_attack(weapon_node:Weapon, direction:int) -> void:
	weapon_node.do_ranged_shot(projectile_scene, sprite_projectile, projectile_speed, direction)
	
