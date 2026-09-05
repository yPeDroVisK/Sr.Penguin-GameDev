extends WeaponResource
class_name SwordResource

@export var swing_arc_degress:float = 90.0

func execute_attack(weapon_node:Weapon, direction:int) -> void:
	weapon_node.do_melee_swing(direction, swing_arc_degress)
