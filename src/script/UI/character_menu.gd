extends CanvasLayer

@onready var bg_dark: ColorRect = $BgDark
@onready var hp_label: Label = $BgDark/Root/VBoxContainer/Content/Right/Stats/HpRow/HpLabel
@onready var coins_label: Label = $BgDark/Root/VBoxContainer/Content/Right/Stats/CoinsRow/CoinsLabel
@onready var speed_label: Label = $BgDark/Root/VBoxContainer/Content/Right/Stats/SpeedRow/SpeedLabel
@onready var dmg_label: Label = $BgDark/Root/VBoxContainer/Content/Right/Stats/DmgRow/DmgLabel
@onready var weapon_slot: PanelContainer = $BgDark/Root/VBoxContainer/Content/Right/EquipArea/LeftSlots/WeaponSlot
@onready var icon_weapon: TextureRect = $BgDark/Root/VBoxContainer/Content/Right/EquipArea/LeftSlots/WeaponSlot/IconWeapon
@onready var name_weapon: Label = $BgDark/Root/VBoxContainer/Content/Right/EquipArea/LeftSlots/WeaponSlot/NameWeapon
@onready var inventory_ui: Control = $BgDark/Root/VBoxContainer/Content/Left/InventoryUi
@onready var btn_continue: Button = $BgDark/Root/VBoxContainer/Footer/BtnContinue
@onready var btn_restart: Button = $BgDark/Root/VBoxContainer/Footer/BtnRestart
@onready var btn_menu: Button = $BgDark/Root/VBoxContainer/Footer/BtnMenu

const MAIN_MENU = "uid://i30ki8v5kqeu"
var _is_open:bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	bg_dark.hide()
	
	btn_continue.pressed.connect(close_menu)
	btn_restart.pressed.connect(_on_restart)
	btn_menu.pressed.connect(_on_main_menu)
	
	GameManager.coins_update.connect(_on_coins_update)
	GameManager.live_update.connect(_on_hp_update)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _is_open: close_menu()
		else: open_menu()
		
func open_menu() -> void:
	_is_open = true
	_refresh_all()
	inventory_ui.show()
	bg_dark.show()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func close_menu() -> void:
	_is_open = false
	inventory_ui.hide()
	bg_dark.hide()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
func _refresh_all() -> void:
	_on_coins_update(GameManager.coins)
	_on_hp_update(GameManager.live)
	_refresh_weapon()
	_refresh_speed()
	
func _on_coins_update(value:int) -> void:
	coins_label.text = str(value)
	
func _on_hp_update(value:int) -> void:
	hp_label.text = "%d / %d" % [value, GameManager.MAX_LIVES]
	
func _refresh_weapon() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player == null or player.current_weapon == null:
		name_weapon.text = "-"
		icon_weapon.texture = null
		return
		
	var sprite = player.current_weapon.get_node_or_null("Sprite2D")
	if sprite:
		icon_weapon.texture = sprite.texture
		
	if player.current_weapon.get("data") and player.current_weapon.data is WeaponResource:
		name_weapon.text = player.current_weapon.data.name
	else:
		name_weapon.text = "Equipada"
	
func _refresh_speed() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		speed_label.text = str(player.speed)
		
		if player.current_weapon and player.current_weapon.get("data"):
			dmg_label.text = str(player.current_weapon.data.damage)
		else:
			dmg_label.text = "0"
			
func _on_restart() -> void:
	close_menu()
	await  get_tree().process_frame
	get_tree().reload_current_scene()
	
func _on_main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU)
