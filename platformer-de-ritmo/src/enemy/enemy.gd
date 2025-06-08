class_name Enemy
extends CharacterBody2D

@onready var area = $Area2D
@export var signal_bus_sender : SignalBusSender


# Process animations
func _process(_delta):
	pass

# Process physics
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	move_and_slide()


func on_body_entered_area(body: Node2D) -> void:
	if body is Player:
		signal_bus_sender.send_player_entered_area(self)
