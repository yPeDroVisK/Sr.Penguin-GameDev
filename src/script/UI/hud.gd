extends CanvasLayer

@onready var coins_counter: Label = $MarginContainer/CoinsContainer/VBoxContainer/CoinsCounter
@onready var lives: Label = $MarginContainer/LifeContainer/VBoxContainer/Lives
@onready var lives_counter: Label = $MarginContainer/LifeContainer/VBoxContainer/LivesCounter
	
func update_coins(new_value:int):
	coins_counter.text = "%04d" % new_value
	
func update_lives(new_value:int):
	lives.text = "Vidas"
	lives_counter.text = "%02d" % new_value
	
func _ready() -> void:
	update_coins(0)
	update_lives(3)
	GameManager.coins_update.connect(update_coins)
	GameManager.live_update.connect(update_lives)
