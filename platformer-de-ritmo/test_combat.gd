extends Node2D

@onready var music = $Music
@onready var atk_good = $Soundfx/AttackGood
@onready var atk_wrong = $Soundfx/AttackWrong
@onready var atk_miss = $Soundfx/AttackMiss
@onready var atk_cyberbeast = $Soundfx/AttackCyberBeast
@onready var arrow_sprite = $Camera/Arrow
@onready var song_beat : AnimationPlayer = $SongBeat
@onready var rhythms : AnimationPlayer = $Rhythms
@onready var signal_bus_sender : SignalBusSender = $SignalBusSender

@export var _beat = false
@export var _rhythm = false

var player: Player

var rhythms_list = [
	["rhythm1", 4], ["rhythm2", 4], ["rhythm3", 5], ["rhythm4", 6], ["rhythm5", 5],
	["rhythm6", 4], ["rhythm7", 3], ["rhythm8", 3], ["rhythm9", 4], ["rhythm10", 6]
]

var in_show_sequence = false
var in_combat_mode = false
var attempted = false
var beat_start = false
var killed_enemy = true
var atk_sequence = []
var current_beat = -1
var attack
var rhythm
	

func _ready() -> void:
	player = Player.get_player(get_tree())	


func _process(_delta: float) -> void:
	$Camera/TestLifeLabel.text = str(player.life)
		
	# Start music a bit earlier to sync it with the rhythms (music is 24s long)
	if not music.playing:
		music.play(23.9)
		
	# Keep the beat "animation" running
	if not song_beat.is_playing():
		song_beat.play("song_beat")
	
	# Wait for beat to show the sequence
	if _beat:
		_beat = false
		if in_show_sequence and not rhythms.is_playing():
			rhythms.play(rhythm[0]) # rhythm[0] contains the rhythm itself

	show_sequence()
	start_combat()


func _on_player_entered_area(enemy) -> void:
	# Preparation to start combat mode, starting with showing the sequence
	player.is_in_combat = true
	current_beat = -1
	Camera.target_object(enemy)
	in_show_sequence = true
	
	# Pick a random rhythm
	rhythm = rhythms_list.pick_random()
	
	# Generate random sequence of attacks
	atk_sequence.clear()
	for ugd in range(rhythm[1]):
		var atk = ["player_attack_up", "player_attack_down", "player_attack_left", "player_attack_right"].pick_random()
		atk_sequence.append(atk)
		

func show_sequence():
	# Keep showing the sequence until it reaches the last element
	if in_show_sequence and current_beat < rhythm[1]: # rhythm[1] contains number of beats
		attack = atk_sequence[current_beat]
		change_sprite((player.attacks_dict[attack])[0]) # contains the arrow sprite's name
		arrow_sprite.visible = true
		
		# If within beat interval
		if _rhythm:
			if beat_start:
				return
				
			# If it's not a beat start, prepare to show the next one
			atk_cyberbeast.play()
			current_beat += 1		
			arrow_sprite.visible = false
			beat_start = true
			
		# If not within the beat interval
		else:
			arrow_sprite.visible = false
			beat_start = false
			
			if current_beat == rhythm[1] - 1:
				current_beat += 1
	
	# If finished showing sequence
	else:
		# Start combat
		if current_beat != -1 and not in_combat_mode:
			current_beat = -1
			in_show_sequence = false
			in_combat_mode = true
			change_sprite("base_arrow")
	

func start_combat():
	# Keep showing the sequence until it reaches the last element
	if in_combat_mode and current_beat < rhythm[1]: # rhythm[1] contains number of beats
		# Waits until the first time the rhythm was played (i.e. to show the sequence) finishes
		if not rhythms.is_playing():
			rhythms.play(rhythm[0]) # rhythm[0] contains the rhythm itself
			
		attack = atk_sequence[current_beat]
		arrow_sprite.visible = true
		
		# If within beat interval
		if _rhythm:
			# If already attempted current beat, skip key input verification
			if attempted:
				return
				
			# If pressed correct key
			if Input.is_action_just_pressed(attack):
				atk_good.play()
				attempted = true
			# If pressed wrong key
			elif Input.is_action_just_pressed("player_attack_up") or Input.is_action_just_pressed("player_attack_down") or Input.is_action_just_pressed("player_attack_left") or Input.is_action_just_pressed("player_attack_right"):
				atk_wrong.play()
				player_was_damaged()
				killed_enemy = false
				attempted = true
			
			# If not beat start (i.e. it is the end of a beat)
			if not beat_start:
				current_beat += 1				
				arrow_sprite.visible = false
				beat_start = true

		# If not within the beat interval
		else:
			# If player did not attack during beat interval
			if not attempted and beat_start:
				atk_miss.play()	
				player_was_damaged()
				killed_enemy = false
			if current_beat == rhythm[1] - 1:
				current_beat += 1	
					
			arrow_sprite.visible = false
			beat_start = false
			attempted = false
	
	# If finished combat
	else:
		if killed_enemy:
			if current_beat != -1 and not in_show_sequence:
				in_combat_mode = false
				exit_combat()
		else:
			reshow_sequence()
	
	
func exit_combat():
	player.is_in_combat = false
	current_beat = -1
	Camera.target_object(player)


func reshow_sequence():
	# At the start of every sequence, assume player has defeated enemy.
	# If player misses a beat, then killed_enemy = false 
	killed_enemy = true
	in_show_sequence = true
	in_combat_mode = false
	current_beat = -1
	

func change_sprite(arrow):
	# Update the arrow sprite texture according to the attack sequence
	var texture = load('res://assets/rhythm_arrows/%s.png' %[arrow])
	arrow_sprite.texture = texture


func player_was_damaged():
	signal_bus_sender.send_player_was_damaged()
