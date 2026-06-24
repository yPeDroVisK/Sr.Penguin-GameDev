extends Control

const SLOT_SCENE = preload("res://UI/inventory_slot_ui.tscn")

@onready var grid_container: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/GridContainer
@onready var tooltip_label: Label = $PanelContainer/TooltipLabel

var slot_scenes:Array = []

func _ready() -> void:
	
	await get_tree().process_frame
	
	var inv = GameManager.inventory
	if inv == null:
		push_error("InventoryUI: GameManager.inventory está null")
		return
	
	setup(inv)
	hide()
	
func setup(inventory:InventoryManager) -> void:
	inventory.inventory_change.connect(_refresh_ui.bind(inventory))
	_create_slots(inventory)
	
func _create_slots(inventory:InventoryManager) -> void:
	# Limpa slots antigos
	for child in grid_container.get_children():
		child.queue_free()
	slot_scenes.clear()
	
	for i in inventory.inventory_size:
		var slot_ui = SLOT_SCENE.instantiate()
		slot_ui.slot_index = i
		grid_container.add_child(slot_ui)
		slot_scenes.append(slot_ui)
	# Clique no slot usa o item
		slot_ui.pressed.connect(func(): inventory.use_item(i))
		
	
func _refresh_ui(inventory: InventoryManager) -> void:
	for i in inventory.slots.size():
		var slot = inventory.get_slot(i)
		var slot_ui = slot_scenes[i]

		if slot.is_empty():
			slot_ui.get_node("TextureRect").texture = null
			slot_ui.get_node("Label").text = ""
		else:
			slot_ui.get_node("TextureRect").texture = slot.item.icon
			# Só mostra número se tiver mais de 1
			var qty_text = str(slot.quantity) if slot.quantity > 1 else ""
			slot_ui.get_node("Label").text = qty_text
	
func _on_slot_hovered(index:int, inventory:InventoryManager) -> void:
	var slot = inventory.get_slot(index)
	if slot.is_empty():
		tooltip_label.hide()
		return
	
	tooltip_label.text = slot.item.display_name + "\n" + slot.item.description
	tooltip_label.show()
	
func _on_unhovered(_index:int) -> void:
	tooltip_label.hide()
