extends CharacterBody2D

const SPEED = 750.0
const JUMP_VELOCITY = -1250.0
const JUMP_BUFFER_TIME = 0.1
const COYOTE_TIME = 0.1

var jump_buffer
var coyote_buffer

@export var player_animations : AnimationPlayer
@export var _is_parrying := false 
@export var _is_falling = false
var is_moving
var can_jump


# Process animations
func _process(_delta):
	var direction := Input.get_axis("player_left", "player_right")
	# If player is moving, flip sprites according to its direction
	if direction != 0:
		$Sprite2D.flip_h = direction > 0
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

	move_and_slide()
	
	
func jump() -> void:
	velocity.y = JUMP_VELOCITY
		
	
func jump_buffer_timeout() -> void:
	jump_buffer = false
	

func coyote_timeout() -> void:
	coyote_buffer = false


func parry():
	player_animations.play("parry")
