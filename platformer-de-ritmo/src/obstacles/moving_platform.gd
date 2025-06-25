# Script para o StaticBody2D
extends MovingObstacle

#@onready var detector = %Area2D  # Area2D é filho do StaticBody2D

@export var detector : Area2D
	
func _ready():	
	# Conecta sinais do Area2D
	detector.body_entered.connect(_on_body_entered)
	detector.body_exited.connect(_on_body_exited)
	start_movement()
	
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
