extends CanvasLayer

@onready var bg_dark: ColorRect = $BgDark
@onready var panel_container: PanelContainer = $BgDark/PanelContainer
@onready var grid_itens: GridContainer = $BgDark/PanelContainer/VBoxContainer/MarginContainer/GridItens
@onready var coins: Label = $BgDark/PanelContainer/VBoxContainer/HeaderPainel/HBoxContainer/Coins
@onready var btn_close: Button = $BgDark/PanelContainer/VBoxContainer/BtnClose


const MARKET_SLOT = preload("uid://3ao80w7gl50m")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	bg_dark.hide()
	btn_close.pressed.connect(close_market)
	GameManager.coins_update.connect(_to_update_coins)
	
func open_market(itens:Array[ItemData]) -> void:
	for child in grid_itens.get_children():
		child.queue_free()
		
	for item in itens:
		var slot = MARKET_SLOT.instantiate()
		grid_itens.add_child(slot)
		slot.config(item)
		slot.buy_requested.connect(_on_buy_requested)
		
	_to_update_coins(GameManager.coins)
	bg_dark.show()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func close_market() -> void:
	bg_dark.hide()
	get_tree().paused = false
	
func _to_update_coins(value:int) -> void:
	coins.text = "Moedas: %d" % value
	
func _on_buy_requested(item:ItemData, qtd:int = 1) -> void:
	var total_cost = item.value * qtd
	
	if GameManager.coins < total_cost:
		print_debug("Saldo Insuficiente")
		return
	
	var sucess:bool = GameManager.inventory.add_item(item,qtd)
	
	if sucess:
		GameManager.coins -= total_cost
		print_debug("Comprou")
	else:
		print_debug("Inv Cheio")
	
func _on_btn_close_pressed() -> void:
	close_market()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	print_debug("Clicouu...")
	
