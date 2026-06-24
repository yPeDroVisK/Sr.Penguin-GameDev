extends Button
class_name InventorySlotUI

@onready var texture_rect: TextureRect = $TextureRect
@onready var quantity_label: Label = $Label
@onready var highlight: Panel = $Panel

var slot_index: int = -1
var current_item: ItemData = null

signal slot_clicked(index:int)
signal slot_hovered(index:int)
signal slot_unhovered(index:int)

func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	clear()

func _on_mouse_entered() -> void:
	set_selected(true)
	slot_hovered.emit(slot_index)
	
func _on_mouse_exited() -> void:
	set_selected(false)
	slot_unhovered.emit(slot_index)
	
func set_item(item: ItemData, quantity: int) -> void:
	current_item = item
	if item == null:
		clear()
		return
	texture_rect.texture = item.icon
	quantity_label.text = str(quantity) if quantity > 1 else ""
	quantity_label.visible = quantity > 1

func clear() -> void:
	current_item = null
	texture_rect.texture = null
	quantity_label.text = ""
	quantity_label.visible = false
	set_selected(false)

func set_selected(value: bool) -> void:
	highlight.visible = value

func _on_pressed() -> void:
	slot_clicked.emit(slot_index)
