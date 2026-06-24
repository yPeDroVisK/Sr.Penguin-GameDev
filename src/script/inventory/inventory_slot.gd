class_name InventorySlot

var item : ItemData = null
var quantity : int = 0

func is_empty() -> bool:
	return item == null
	
func can_add(amount:int) -> bool:
	if is_empty():
		return true
	# Se já tem item, verifica se cabe mais na stack
	return quantity + amount <= item.max_stack
	
func add(new_item:ItemData,amount:int = 1) -> int:
	if is_empty():
		item = new_item
		quantity = amount
		return 0 # Retorna a sobra (0 = coube tudo)
	
	if item.id != new_item.id:
		return amount # Item diferente, não pode empilhar
	
	var space_left = item.max_stack - quantity # Espaços restantes
	var to_add = min(amount, space_left) # min() Retorna o menor valor
	quantity += to_add
	return amount - to_add # Retorna o que não coube
	
func remove(amount:int = 1) -> void:
	quantity -= amount
	if quantity <= 0:
		item = null
		quantity = 0
