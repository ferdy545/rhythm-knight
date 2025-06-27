extends CharacterBody2D
class_name Player

@export var life = 10

const SPEED = 750.0
const JUMP_VELOCITY = -1250.0
const JUMP_BUFFER_TIME = 0.1
const COYOTE_TIME = 0.1
const PLAYER_GROUP = &"PLAYER"

var jump_buffer
var coyote_buffer

@export var enemy : Script
@export var player_animations : AnimationPlayer
@export var _fisished_dying := false
@export var _is_getting_damaged := false
@export var _is_attacking := false
@export var _is_parrying := false 
@export var _is_falling := false
var is_moving
var can_jump
var is_in_combat: bool
var game_over_scene = preload("res://src/obstacles/after_death.tscn")
	 

var attacks_dict = {
	"player_attack_up": ["up_arrow", "jump_attack"],
	"player_attack_down": ["down_arrow", "parry"],
	"player_attack_left": ["left_arrow", "block_attack"],
	"player_attack_right": ["right_arrow", "basic_attack"]
  # "input key": ["arrow sprite", "animation"]
}


func _init() -> void:
	add_to_group(PLAYER_GROUP)


# Process animations
func _process(_delta):
	# Handle player death
	if life <= 0:
		die()
			
	# If player life is more than zero:	
	else:
		# If player is not in combat
		if not is_in_combat:
			var direction := Input.get_axis("player_left", "player_right")
			# If player is moving, flip sprites according to its direction
			if direction != 0:
				$Sprite2D.scale.x = abs($Sprite2D.scale.x) if direction > 0 else -abs($Sprite2D.scale.x)
			if not _is_attacking:		
				# If on floor, check if player just fell, is moving or is idling
				if is_on_floor():
					can_jump = true
					if _is_falling:
						player_animations.play("fall")
					else:
						is_moving = Input.is_action_pressed("player_left") or Input.is_action_pressed("player_right")
						if is_moving and velocity.x != 0:
							player_animations.play("walk")
						else:
							player_animations.play("idle")
				# If not on floor, player is falling
				else:
					_is_falling = true
					if Input.is_action_just_pressed("player_jump") and can_jump:
						player_animations.play("jump")
						can_jump = false
				
				# Attacks
				if Input.is_action_just_pressed("player_parry"):
					player_animations.play("parry")
					
			else:
				if Input.is_action_just_pressed("player_parry"):
					player_animations.play("parry")
		
		# If player is in combat, manage attack animations		
		else:
			if not _is_getting_damaged:
				if Input.is_action_just_pressed("player_attack_up"):
					player_animations.play("jump_attack")
				elif Input.is_action_just_pressed("player_attack_down"):
					player_animations.play("parry")
				elif Input.is_action_just_pressed("player_attack_left"):
					player_animations.play("block_attack")
				elif Input.is_action_just_pressed("player_attack_right"):
					player_animations.play("basic_attack")
				elif not _is_attacking:
					player_animations.play("idle")
			else:
				player_animations.play("damaged")


# Process physics
func _physics_process(delta: float) -> void:
	# If not on floor, apply gravity force and start coyote timer
	if not is_on_floor():
		velocity += get_gravity() * delta
		get_tree().create_timer(COYOTE_TIME).timeout.connect(coyote_timeout)
	# If on floor, jump if jump buffer has not timed out and reset coyote time
	else:
		if jump_buffer:
			jump()
			jump_buffer = false
		coyote_buffer = true
	
	# Lock player's movement if in combat mode
	if not is_in_combat:
		# Handle jump
		if Input.is_action_just_pressed("player_jump"):
			# If on floor, jump normally
			if is_on_floor():
				jump()
			# If not on floor, jump if within coyote time and start jump buffer timer
			else:
				if coyote_buffer:
					jump()
					coyote_buffer = false
				jump_buffer = true
				get_tree().create_timer(JUMP_BUFFER_TIME).timeout.connect(jump_buffer_timeout)
							
		# Get the input direction and handle the movement/deceleration
		var direction := Input.get_axis("player_left", "player_right")
		if direction:
			if is_on_floor():
				velocity.x = move_toward(velocity.x, direction * SPEED, 150)
			else:
				velocity.x = move_toward(velocity.x, direction * SPEED, 100)
		else:
			velocity.x = move_toward(velocity.x, 0, 75)
	else:
		velocity.x = 0
	move_and_slide()
	
	
func jump() -> void:
	velocity.y = JUMP_VELOCITY
		
	
func jump_buffer_timeout() -> void:
	jump_buffer = false
	

func coyote_timeout() -> void:
	coyote_buffer = false


func parry():
	player_animations.play("parry")
	
	
func _on_player_was_damaged() -> void:
	_is_getting_damaged = true
	life -= 1;
	player_animations.stop()

func die():
	player_animations.play("death")
	await player_animations.animation_finished
	get_tree().current_scene.add_child(game_over_scene.instantiate())
	get_tree().paused = true 
	if _fisished_dying:
		get_tree().current_scene.add_child(game_over_scene.instantiate())



static func get_player(scene_tree: SceneTree):
	return scene_tree.get_first_node_in_group(PLAYER_GROUP)
	
