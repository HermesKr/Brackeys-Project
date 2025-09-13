extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

enum PlayerState { ALIVE, DEAD }

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const COYOTE_TIME = 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_alive := true
var coyote_timer := 0.0
var direction
var state: PlayerState = PlayerState.ALIVE

func _physics_process(delta):
	match state:
		PlayerState.ALIVE:
			process_alive(delta)
		PlayerState.DEAD:
			process_dead(delta)

func process_alive(delta):
	# Gravity
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
		
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Jump
	if Input.is_action_just_pressed("jump") and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0
		
	# Movement
	var direction = Input.get_axis("move_left", "move_right")
	
	# Flip sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	# Animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jumping")
		
	# Velocity
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	
func process_dead(delta):
	velocity.y += gravity * delta
	animated_sprite.play("death")
	move_and_slide()
