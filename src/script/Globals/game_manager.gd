extends Node
	
signal coins_update(new_value:int)
signal inventory_ready(inv:InventoryManager)
	
var inventory:InventoryManager = null:
	set(value):
		inventory = value
		if value != null:
			inventory_ready.emit(value)
	
var coins:int = 0:
	set(value):
		coins = max(value, 0)
		coins_update.emit(coins)
	
func add_coin(amount:int) -> void:
	coins += amount
	
	
