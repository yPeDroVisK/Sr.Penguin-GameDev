extends Node

@export_group("Propriedades")
@export_file("*.tscn") var Next_Scene: String = ""

@onready var interactable_area: InteractableArea = $InteractableArea
@onready var animation: AnimationPlayer = $Animation


func _ready() -> void:
	interactable_area.texto_prompt = "[E] Portal"
	interactable_area.interacted.connect(change_scene_on_click)
	interactable_area.body_entered.connect(_on_body_entered)
	interactable_area.body_exited.connect(_on_body_exited)
	
func change_scene_on_click(_interactor: Node) -> void:
	call_deferred("_load_next_scene")

func _load_next_scene():
	get_tree().change_scene_to_file(Next_Scene)
	
func _on_body_entered(body:Node2D) -> void:
	if body.is_in_group("Player"):
		animation.play("Pulsar")
	
func _on_body_exited(body:Node2D) -> void:
	if body.is_in_group("Player"):
		animation.play("Portal", 0.3)
