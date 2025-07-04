extends Node2D

var current_scene_root:Node 
@export var level_scene:PackedScene


func _change_to_scene(node: Node):
	current_scene_root.queue_free()
	await current_scene_root.tree_exited
	current_scene_root = node
	get_tree().root.add_child(node)


func go_to_level():
	_change_to_scene(level_scene.instantiate())
