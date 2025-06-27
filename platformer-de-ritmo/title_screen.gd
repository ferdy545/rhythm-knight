extends Control


func _ready() -> void:
	SceneManager.current_scene_root = self
	

func _on_play_pressed() -> void:
	SceneManager.go_to_level()


func _on_credits_pressed() -> void:
	pass # Replace with function body.


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()
