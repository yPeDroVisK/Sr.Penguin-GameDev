extends Resource
class_name WeaponResource

@export_group("Identidade")
@export var weapon_name:String = ""
@export var damage:int = 0
@export var fire_rate:float = 0.0

@export_group("Sprites")
@export var icon:Texture2D
@export var sprite_equipped:SpriteFrames

## Método virtual — cada arma filha (SwordResource, BowResource) sobrescreve isso
func execute_attack(_weapon_node: Weapon, _direction: int) -> void:
	push_warning("execute_attack não implementado para " + weapon_name)
