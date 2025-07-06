extends Node2D

@onready var camera = $Camera
@onready var music = $Music
@onready var enemy_detect = $Soundfx/EnemyDetect
@onready var enemy_death = $Soundfx/EnemyDeath
@onready var atk_good = $Soundfx/AttackGood
@onready var atk_wrong = $Soundfx/AttackWrong
@onready var atk_miss = $Soundfx/AttackMiss
@onready var atk_cyberbeast = $Soundfx/AttackCyberBeast
@onready var arrow_sprite = $Camera/Arrow
@onready var song_beat : AnimationPlayer = $SongBeat
@onready var rhythms : AnimationPlayer = $Rhythms
@onready var signal_bus_sender : SignalBusSender = $SignalBusSender
@onready var signal_bus_receiver : SignalBusReceiver = $SignalBusReceiver
@onready var player_sprite : Sprite2D = $CharacterBody2D/Sprite2D
@export var you_win_screen : Node 


@export var _beat = false
@export var _rhythm = false

var player: Player
var enemy: Enemy

var rhythms_list = [
	["rhythm1", 4], ["rhythm2", 4], ["rhythm3", 5], ["rhythm4", 6], ["rhythm5", 5],
	["rhythm6", 4], ["rhythm7", 3], ["rhythm8", 3], ["rhythm9", 4], ["rhythm10", 6]
]

var arrow_instance
var arrow_pos = 0
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
	SceneManager.current_scene_root = self
	player = Player.get_player(get_tree())	


func _process(_delta: float) -> void:
	$CanvasLayer/LifeLabel.text = "❤ " + str(player.life)

	if player.life > 0:
		show_sequence()
		start_combat()


func _on_player_entered_area(enemy) -> void:
	enemy_detect.play()
	# Preparation to start combat mode, starting with showing the sequence
	player.is_in_combat = true
	enemy.is_in_combat = true
	self.enemy = enemy
	current_beat = -1
	Camera.target_object(enemy)
	in_show_sequence = true
	
	var enemy_sprite = enemy.get_node("Sprite2D")
	
	# Make player and enemy face each other when in combat	
	if player.global_position.x < enemy.global_position.x:
		player_sprite.scale.x = abs(player_sprite.scale.x)
		enemy_sprite.scale.x = -abs(enemy_sprite.scale.x)
	else:
		player_sprite.scale.x = -abs(player_sprite.scale.x)
		enemy_sprite.scale.x = abs(enemy_sprite.scale.x)
		
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
		if current_beat == -1:
			arrow_pos = 0
			
		# If within beat interval
		if _rhythm:
			if not beat_start:
				atk_cyberbeast.play()
				attack = atk_sequence[current_beat + 1]
				# (player.attacks_dict[attack])[0] contains the arrow sprite's name
				show_sprite((player.attacks_dict[attack])[0], arrow_pos)
				arrow_pos = arrow_pos + 1
				current_beat += 1		
				beat_start = true
			
		# If not within the beat interval
		else:
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
			#arrow_sprite = show_sprite("base_arrow", arrow_pos)
			show_rhythm_cue()
	

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
			enemy_attack()
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
				atk_miss.play();
				player_was_damaged()
				killed_enemy = false
			if current_beat == rhythm[1] - 1:
				current_beat += 1	
					
			arrow_sprite.visible = false
			beat_start = false
			attempted = false
	
	# If finished combat
	else:
		if not in_show_sequence:
			# Delete all arrows before showing them again
			for child in $".".get_children():
				if child.get_class() == "Sprite2D":
					child.queue_free()
				
		if killed_enemy:
			if current_beat != -1 and not in_show_sequence:
				in_combat_mode = false
				enemy_killed()
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
	

func show_sprite(arrow, pos):
	# Instantiate a sprite for the arrow, load the texture and update the position where it is shown
	arrow_instance = Sprite2D.new()
	arrow_instance.texture = load('res://assets/rhythm_arrows/%s.png' %[arrow])
	$".".add_child(arrow_instance)
	var position = Vector2(camera.position.x - 954, camera.position.y + 450)
	arrow_instance.set_position(position + Vector2(pos*256, 0))
	#arrow_instance.visible = true
	return arrow_instance
	
	
func show_rhythm_cue():
	var texture = load('res://assets/rhythm_arrows/base_arrow.png')
	arrow_sprite.texture = texture


func player_was_damaged():
	signal_bus_sender.send_player_was_damaged()
	

func enemy_attack():
	signal_bus_sender.send_enemy_attack(enemy)
	
	
func enemy_killed():
	signal_bus_sender.send_enemy_was_killed(enemy)
	enemy_death.play()

		
func _on_player_wins_body_entered(body: Node2D) -> void:
	if body is Player:
		you_win_screen.get_child(0).visible = true
		get_tree().paused = true 


func _on_signal_bus_receiver_beat_changed() -> void:
	if in_show_sequence and not rhythms.is_playing():
		rhythms.play(rhythm[0]) # rhythm[0] contains the rhythm itself
