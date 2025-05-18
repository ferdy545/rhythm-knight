extends CharacterBody2D

const SPEED = 750.0
const JUMP_VELOCITY = -1250.0
const JUMP_BUFFER_TIME = 0.1
const COYOTE_TIME = 0.1

@export var _is_parrying := false 
@export var player_animations : AnimationPlayer
var jump_buffer
var coyote_buffer



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
			velocity.x = move_toward(velocity.x, direction * SPEED, 60)
		else:
			velocity.x = move_toward(velocity.x, direction * SPEED, 30)
	else:
		velocity.x = move_toward(velocity.x, 0, 45)

	move_and_slide()
	
	
func jump() -> void:
	velocity.y = JUMP_VELOCITY
	
	
func jump_buffer_timeout() -> void:
	jump_buffer = false
	

func coyote_timeout() -> void:
	coyote_buffer = false

func parry():
	player_animations.play("parry")
