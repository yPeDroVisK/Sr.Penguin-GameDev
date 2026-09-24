extends CanvasLayer

@onready var coins_counter: Label = $MarginContainer/CoinsContainer/VBoxContainer/CoinsCounter
@onready var texture_progress_bar: TextureProgressBar = $MarginContainer/LifeContainer/VBoxContainer/TextureProgressBar

func update_coins(new_value:int) -> void:
	coins_counter.text = "%04d" % new_value
	
func update_health(new_value:int, max_health:int) -> void:
	max_health = new_value
	texture_progress_bar.value = max_health
	
func _ready() -> void:
	update_coins(0)
	update_health(GameManager.health,GameManager.MAX_HEALTH)
	GameManager.coins_update.connect(update_coins)
	GameManager.health_update.connect(update_health)
	
