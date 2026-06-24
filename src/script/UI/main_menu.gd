extends Control

@export_file var next_scene : String = ""

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(next_scene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
