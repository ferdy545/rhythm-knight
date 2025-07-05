extends Control

@export var level_scene : PackedScene
func _on_button_pressed() -> void:
	get_tree().paused = false 
	var title_scene = load("res://title_screen.tscn")
	var title = title_scene.instantiate()
	SceneManager._change_to_scene(title)
