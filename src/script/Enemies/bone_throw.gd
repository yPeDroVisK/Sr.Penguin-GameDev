extends Area2D

@onready var bone_throw_sprite: AnimatedSprite2D = $AnimatedSprite2D

var speed = 60
var direction = 1

func _process(delta: float) -> void:
	position.x += speed * delta * direction
	
func set_direction(bone_direction):
	direction = bone_direction
	bone_throw_sprite.flip_h = direction < 0
	
func _on_self_destruct_timer_timeout() -> void:
	queue_free()
	
func _on_area_entered(_area: Area2D) -> void:
	queue_free()
	
func _on_body_entered(_body: Node2D) -> void:
	queue_free()
