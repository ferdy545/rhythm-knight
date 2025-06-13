extends Node

@export var bpm = 80
@export var interval_radius = 15
var action = "player_parry"
var scale_factor = 0
var final_angle = 120
@export var rotation = 0

func _process(delta):
	#var idle_piece = $IdlePiece
	var mobile_piece = $IdlePiece/MobilePiece
	#var style_box: StyleBoxFlat = idle_piece.get_theme_stylebox("panel")
	
	# Behavior
	rotation += delta * bpm * 2
	mobile_piece.rotation_degrees = rotation
	scale_factor = lerp(1.0, 1.0/3.0, rotation/90)
	mobile_piece.scale = Vector2(scale_factor, scale_factor)
	
	# Restart
	if abs(rotation - final_angle) < delta * bpm * 2:
		rotation = 0
		scale_factor = 1.0	
	
	if Input.is_action_just_pressed(action):
		if (rotation >= 90-interval_radius) and (rotation <= 90+interval_radius):
			#style_box.border_color = Color(0.0, 1.0, 0.0)
			#idle_piece.add_theme_stylebox_override("panel", style_box)
			print("GOOD")
		else:
			#style_box.border_color = Color(1.0, 1.0, 1.0)
			#idle_piece.add_theme_stylebox_override("panel", style_box)
			print("miss")
