class_name Enemy
extends CharacterBody2D

@onready var area = $Area2D
@export var signal_bus_sender : SignalBusSender
@export var enemy_animations : AnimationPlayer
@export var _is_attacking := false
@export var _enemy_was_killed := false
@export var _finished_dying := false 

var is_in_combat: bool


# Process animations
func _process(_delta):
	# Don't run any other animation until "detect" is finished
	if enemy_animations.current_animation == "detect":
		return
	
	# If enemy was killed
	if _enemy_was_killed:
		enemy_animations.play("death")
		if _finished_dying:
			queue_free()
	# If enemy was not killed
	else:
		if is_in_combat:
			if _is_attacking:
				enemy_animations.play("attack")
			else:
				enemy_animations.play("waiting")
		else:
			enemy_animations.play("idle")
	
	
# Process physics
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	move_and_slide()


func on_body_entered_area(body: Node2D) -> void:
	if body is Player:
		signal_bus_sender.send_player_entered_area(self)
		enemy_animations.play("detect")


func _on_enemy_attack(enemy) -> void:
	if enemy != self:
		return
	_is_attacking = true


func _on_enemy_was_killed(enemy) -> void:
	if enemy != self:
		return
	_enemy_was_killed = true
