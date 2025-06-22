# Script para o StaticBody2D
extends MovingObstacle

#@onready var detector = %Area2D  # Area2D é filho do StaticBody2D

@export var detector : Area2D
	
func _ready():	
	start_movement()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()
