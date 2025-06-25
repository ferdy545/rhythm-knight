extends StaticBody2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var tween = get_tree().create_tween()
		tween.tween_property($Sprite2D, "modulate", Color.RED, 2)
		tween.tween_callback(self.queue_free)
