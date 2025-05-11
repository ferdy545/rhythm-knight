extends Node

@export var bpm = 120
@export var dificulty = 1

func _process(delta):
	var scale_factor
	var mobile_piece = $IdlePiece/MobilePiece
	
	# Behavior
	mobile_piece.rotation_degrees += delta * bpm
	scale_factor = lerp(1.0, 1.0/3.0, mobile_piece.rotation_degrees/90)
	mobile_piece.scale = Vector2(scale_factor, scale_factor)
	
	# Restart
	if abs(mobile_piece.rotation_degrees - 90) < delta * bpm:
		mobile_piece.rotation_degrees = 0
		scale_factor = 1.0
		
