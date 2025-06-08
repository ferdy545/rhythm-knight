extends Node2D

@onready var music = $Music
@onready var atk_good = $Soundfx/AttackGood
@onready var atk_wrong = $Soundfx/AttackWrong
@onready var atk_miss = $Soundfx/AttackMiss
@onready var atk_cyberbeast = $Soundfx/AttackCyberBeast
@onready var player = $CharacterBody2D
@onready var arrow_sprite = $Camera/Arrow
@onready var song_beat : AnimationPlayer = $SongBeat
@onready var rhythms : AnimationPlayer = $Rhythms

@export var _lock_player = false
@export var _beat = false
@export var _rhythm = false

var rhythms_list = [
	["rhythm1", 4], ["rhythm2", 4], ["rhythm3", 5], ["rhythm4", 6], ["rhythm5", 5],
	["rhythm6", 4], ["rhythm7", 3], ["rhythm8", 3], ["rhythm9", 4], ["rhythm10", 6]
]

@onready var attacks = {
	"player_attack_up": "up_arrow",
	"player_attack_down": "down_arrow",
	"player_attack_left": "left_arrow",
	"player_attack_right": "right_arrow"
}

var in_show_sequence = false
var in_combat_mode = false
var attempted = false
var beat_start = false
var killed_enemy = true
var atk_sequence = []
var attack
var rhythm
var i = -1


func _process(_delta: float) -> void:
	$Camera/TestLifeLabel.text = str(player.life)
	
	# Start music a bit earlier to sync it with the rhythms (music is 24s long)
	if not music.playing:
		music.play(23.9)
	
	# Wait for beat to show the sequence
	if _beat:
		_beat = false
		if not rhythms.is_playing() and in_show_sequence:
			rhythms.play(rhythm[0])
		
	# Keep the beat "animation" running
	if not song_beat.is_playing():
		song_beat.play("song_beat")
	
	# Keep showing the sequence until it reaches the last element (rhythm[1] contains number of beats)
	if in_show_sequence and i < rhythm[1]:
		attack = atk_sequence[i]
		change_sprite(attacks[attack]) 
		arrow_sprite.visible = true
		
		# If within beat interval
		if _rhythm:
			if not beat_start:
				atk_cyberbeast.play()
				i = i + 1		
				arrow_sprite.visible = false
				beat_start = true
		# If not within the beat interval
		else:
			arrow_sprite.visible = false
			beat_start = false
			if i == rhythm[1] - 1:
				i = i + 1
	
	# If finished showing sequence
	else:
		# Start combat
		if i != -1 and not in_combat_mode:
			i = -1
			in_show_sequence = false
			in_combat_mode = true
			change_sprite("base_arrow")


func _physics_process(_delta: float) -> void:
	if player.life <= 0:
		get_tree().change_scene_to_file("res://test_death.tscn")
	
	# Keep showing the sequence until it reaches the last element (rhythm[1] contains number of beats)
	if in_combat_mode and i < rhythm[1]:
		# Waits until "showing the sequence" actually finishes (rhythm[0] contains the rhythm itself)
		if not rhythms.is_playing():
			rhythms.play(rhythm[0])
			
		attack = atk_sequence[i]
		arrow_sprite.visible = true
		
		# If within beat interval
		if _rhythm:
			if not attempted:
				# If pressed correct key
				if Input.is_action_just_pressed(attack):
					atk_good.play()
					attempted = true
				# If pressed wrong key
				elif Input.is_action_just_pressed("player_attack_up") or Input.is_action_just_pressed("player_attack_down") or Input.is_action_just_pressed("player_attack_left") or Input.is_action_just_pressed("player_attack_right"):
					atk_wrong.play()
					player.life -= 1
					killed_enemy = false
					attempted = true
			
			# If not beat start (i.e. it is the end of a beat)
			if not beat_start:
				i = i + 1				
				arrow_sprite.visible = false
				beat_start = true

		# If not within the beat interval
		else:
			# If player did not attack during beat interval
			if not attempted and beat_start:
				atk_miss.play()	
				player.life -= 1
				killed_enemy = false
			if i == rhythm[1] - 1:
				i = i + 1		
			arrow_sprite.visible = false
			beat_start = false
			attempted = false
	
	# If finished combat
	else:
		if killed_enemy:
			if i != -1 and not in_show_sequence:
				in_combat_mode = false
				exit_combat()
		else:
			# Show the same sequence again
			killed_enemy = true
			in_show_sequence = true
			in_combat_mode = false
			i = -1


func _on_player_entered_area(enemy) -> void:
	_lock_player = true
	i = -1
	Camera.target_object(enemy)
	in_show_sequence = true
	
	rhythm = rhythms_list.pick_random()
	
	# Generate random sequence of attacks
	atk_sequence.clear()
	for ugd in range(rhythm[1]):
		var atk = ["player_attack_up", "player_attack_down", "player_attack_left", "player_attack_right"].pick_random()
		atk_sequence.append(atk)
	
	
func exit_combat():
	_lock_player = false
	i = -1
	Camera.target_object(player)
	

func change_sprite(arrow):
	# Update the arrow sprite texture according to the attack sequence
	var texture = load('res://assets/rhythm_arrows/%s.png' %[arrow])
	arrow_sprite.texture = texture
