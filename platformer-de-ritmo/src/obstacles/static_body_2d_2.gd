# Script para o StaticBody2D
extends StaticBody2D

@onready var tween = create_tween()
@onready var detector = $Area2D  # Area2D é filho do StaticBody2D

@export var delta_pos : Vector2
@export var time_to_end : float
@export var time_to_start : float

var last_position : Vector2
var bodies_on_platform : Array[CharacterBody2D] = []

func _ready():
	last_position = global_position
	
	# Conecta sinais do Area2D
	detector.body_entered.connect(_on_body_entered)
	detector.body_exited.connect(_on_body_exited)

	var start_pos = global_position
	var end_pos = start_pos + delta_pos

	tween.tween_property(self, "global_position", end_pos, time_to_end)\
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(self, "global_position", start_pos, time_to_start)\
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	tween.set_loops()
	
	set_physics_process(true)

func _physics_process(_delta):
	var delta_move = global_position - last_position
	
	# Move apenas os corpos que estão realmente na plataforma
	for body in bodies_on_platform:
		if is_instance_valid(body):
			body.global_position += delta_move
	
	last_position = global_position

func _on_body_entered(body: Node2D):
	print("Corpo entrou: ", body.name)  # Debug
	if body is CharacterBody2D and body not in bodies_on_platform:
		bodies_on_platform.append(body)

func _on_body_exited(body: Node2D):
	print("Corpo saiu: ", body.name)  # Debug
	if body in bodies_on_platform:
		bodies_on_platform.erase(body)
