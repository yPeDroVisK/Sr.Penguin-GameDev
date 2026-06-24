extends Node
class_name InventoryManager

@export var inventory_size:int = 20

signal item_added(slot_index:int , item:ItemData, quantity:int)
signal item_removed(slot_index:int , item:ItemData)
signal inventory_change()

var slots:Array[InventorySlot] = []

func _ready() -> void:
	init_inv()
	
func init_inv() -> void:
	for i in inventory_size:
		slots.append(InventorySlot.new())

func add_item(item:ItemData, quantity:int = 1) -> bool:
	var remaining = quantity
	
	for i in slots.size():
		if not slots[i].is_empty() and slots[i].item.id == item.id:
			remaining = slots[i].add(item, remaining)
			if remaining == 0:
				item_added.emit(i, item, quantity)
				inventory_change.emit()
				return true
	
	for i in slots.size():
		if slots[i].is_empty():
			remaining = slots[i].add(item , remaining)
			if remaining == 0:
				item_added.emit(i, item , quantity)
				inventory_change.emit()
				return true
	
	print("Inventario Cheioooo")
	return false # Caso o inventario esteja cheio
	
func remove_item(item_id:String, quantity:int = 1) -> bool:
	if not has_item(item_id, quantity):
		return false
		
	var remaining = quantity
	for i in slots.size():
		if not slots[i].is_empty() and slots[i].item.id == item_id:
			var to_remove = min(remaining, slots[i].quantity)
			slots[i].remove(to_remove)
			remaining -= to_remove
			item_removed.emit(i, slots[i].item)
			if remaining == 0:
				break
				
	inventory_change.emit()
	return true

func has_item(item_id:String, quantity:int = 1) -> bool:
	return get_item_count(item_id) >=  quantity
	
func get_item_count(item_id:String) -> int:
	var total = 0
	for slot in slots:
		if not slot.is_empty() and slot.item.id == item_id:
			total += slot.quantity
	return total
		
func get_slot(index:int) -> InventorySlot:
	return slots[index]
