extends Node2D

@export var player : CharacterBody2D

func _process(_delta):
	if Input.is_action_just_pressed("player_parry"):
		player.parry()
