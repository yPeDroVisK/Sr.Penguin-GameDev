extends Node
	
signal health_update(new_value:int, max_value:int)
signal coins_update(new_value:int)
signal inventory_ready(inv:InventoryManager)
signal player_died()
signal weapon_changed(weapon:WeaponResource)
	
const STARTING_HEALTH:int = 10
const  MAX_HEALTH:int = 10
	
var selected_weapon:WeaponResource = null:
	set(value):
		selected_weapon = value
		weapon_changed.emit()
	
var inventory:InventoryManager = null:
	set(value):
		inventory = value
		if value != null:
			inventory_ready.emit(value)
	
var coins:int = 0:
	set(value):
		coins = max(value, 0)
		coins_update.emit(coins)
	
var health:int = 10:
	set(value):
		var old_health = health
		health = clamp(value,0,MAX_HEALTH)
		health_update.emit(health,MAX_HEALTH)
		if health <= 0 and old_health > 0:
			player_died.emit()
	
func add_coin(amount:int) -> void:
	coins += amount
	
func heal(amount:int) -> void:
	health += amount
	
func reset_health() -> void:
	health = STARTING_HEALTH
	
func take_damage(amount:int) -> void:
	health -= amount
	
