extends Control

@export var level_scene : PackedScene
func _on_button_pressed() -> void:
	get_tree().paused = false 
	SceneManager.go_to_level()
