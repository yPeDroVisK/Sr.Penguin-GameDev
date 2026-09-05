extends PanelContainer

signal buy_requested(item:ItemData)

@onready var icon_texture: TextureRect = $VBoxContainer/IconPanel/IconTexture
@onready var item_name: Label = $VBoxContainer/InfoContainer/ItemName
@onready var item_desc: Label = $VBoxContainer/InfoContainer/ItemDesc
@onready var item_stats: Label = $VBoxContainer/InfoContainer/ItemStats
@onready var price: Label = $VBoxContainer/FooterPanel/HBoxContainer/Price
@onready var btn_buy: Button = $VBoxContainer/FooterPanel/HBoxContainer/PanelContainer/BtnBuy

var _item:ItemData

func _ready() -> void:
	btn_buy.pressed.connect(_on_buy_pressed)
	custom_minimum_size = Vector2(140, 180)

func config(item:ItemData, current_coins:int = 0) -> void:
	_item = item
	icon_texture.texture = item.icon
	item_name.text = item.display_name
	item_desc.text = item.description
	item_stats.text = _stats_item(item)
	item_stats.modulate = _color_stats(item)
	price.text = str("value: %d" % item.value)
	to_update_coins(current_coins)
	
func _stats_item(item:ItemData) -> String:
	match  item.item_type:
		# ItemData.ItemType.WEAPON: return "Damage: %d" % item.damage
		ItemData.ItemType.ARMOR: return "Defesa: %d" % item.defense
		ItemData.ItemType.CONSUMABLE: return "Cura %d HP" % item.heal_amount
	return ""
	
func _color_stats(item:ItemData) -> Color:    
	match item.item_type:
		# ItemData.ItemType.WEAPON:     return Color(0.91, 0.64, 0.35)  # laranja
		ItemData.ItemType.ARMOR:      return Color(0.48, 0.71, 0.83)  # azul
		ItemData.ItemType.CONSUMABLE: return Color(0.83, 0.35, 0.49)  # rosa
	return Color.WHITE
	
func to_update_coins(coins:int) -> void:
	if _item == null: return
	var can = GameManager.coins >= _item.value
	btn_buy.disabled = not can
	btn_buy.text = "Buy" if can else "Insufficient funds"
	
func _on_buy_pressed() -> void:
	buy_requested.emit(_item)
