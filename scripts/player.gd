extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const COYOTE_TIME = 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_alive := true
var coyote_timer := 0.0
var direction

func _physics_process(delta):
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_alive and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0

	# Get the input direction that can be 1, 0 or -1.
	if is_alive:
		direction = Input.get_axis("move_left", "move_right")
	
	# Flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	if is_alive:
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jumping")
	else:
		animated_sprite.play("death")
	
	# Apply the movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

