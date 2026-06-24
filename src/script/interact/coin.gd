extends Area2D

@onready var animation: AnimationPlayer = $Animation

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body:Node2D):
	if body.is_in_group("Player"):
		GameManager.add_coin(1)
		set_deferred("monitoring", false)
		animation.play("Collect")
		await animation.animation_finished
		queue_free()
