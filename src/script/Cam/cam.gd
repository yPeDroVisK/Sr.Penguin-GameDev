extends Camera2D

var target : Node2D

func _ready() -> void:
	get_target()
	
func _process(_delta: float) -> void:
	global_position = target.global_position

func get_target():
	var nodes_player = get_tree().get_nodes_in_group("Player")
	if nodes_player.size() == 0:
		push_error("Sem entitade no grupo Player")
		return
	target = nodes_player[0]
