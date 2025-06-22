extends Node2D

class_name MovingObstacle

@onready var tween = create_tween()
#@onready var detector = %Area2D  # Area2D é filho do StaticBody2D

@export var delta_pos : Vector2
@export var time_to_end : float
@export var time_to_start : float

var last_position : Vector2
var bodies_on_platform : Array[CharacterBody2D] = []

func start_movement():
	last_position = global_position

	var start_pos = global_position
	var end_pos = start_pos + delta_pos

	tween.tween_property(self, "global_position", end_pos, time_to_end)\
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(self, "global_position", start_pos, time_to_start)\
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	tween.set_loops()
	
func _physics_process(delta: float) -> void:
	last_position = global_position
