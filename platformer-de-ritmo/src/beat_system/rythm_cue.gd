extends Node

@export var bpm = 120
@export var dificulty = 1

# Debug
var chance = 0 
var score = 0 

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
		
		# Debug
		chance += 1
	
	# Debug
	$Debug/DebugChanceLabel.text = str(score)
	print(mobile_piece.rotation_degrees)


#Debug
func _on_debug_button_pressed():
	var mobile_piece = $IdlePiece/MobilePiece
	if abs(mobile_piece.rotation_degrees/90) > (0.5/dificulty):
		score += 1
	else:
		score -= 1
