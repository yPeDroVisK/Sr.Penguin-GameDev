extends Node
	
signal live_update(new_value:int)
signal coins_update(new_value:int)
	
const MAX_LIVES:int = 5
const STARTING_LIVES:int = 3
	
var inventory:InventoryManager = null
	
var coins:int = 0:
	set(value):
		coins = max(value, 0)
		coins_update.emit(coins)
	
var live:int = STARTING_LIVES:
	set(value):
		clamp(value,0,MAX_LIVES)
		live_update.emit(live)
	
func add_coin(amount:int) -> void:
	coins += amount
	
func lose_lives(amount:int) -> void:
	live -= amount
	
func add_lives(amount:int) -> void:
	live += amount
