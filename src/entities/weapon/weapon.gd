extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer_shot: Timer = $TimerShoot

var data:WeaponResource
var can_fire:bool = true

func _ready() -> void:
	timer_shot.timeout.connect(_on_timer_timeout)

func config(new_data:WeaponResource) -> void:
	data = new_data
	sprite_2d.texture = data.texture
	timer_shot.wait_time = data.fire_rate
	
func shoot() -> void:
	if can_fire and data:
		can_fire = false
		timer_shot.start()
	
func _on_timer_timeout() -> void:
	can_fire = true
