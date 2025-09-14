extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape_2d = %CollisionShape2D
@onready var held_item_location = $HeldItemLocation
@onready var pickup_area = $PickupArea

enum PlayerState { ALIVE, DEAD }

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const COYOTE_TIME = 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_alive := true
var coyote_timer := 0.0
var direction := 1
var state: PlayerState = PlayerState.ALIVE
var held_crate: Crate = null

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
	var input = Input.get_axis("move_left", "move_right")
	
	# Flip sprite
	if input != 0:
		direction = sign(input)
		animated_sprite.flip_h = direction == -1
		held_item_location.position.x = abs(held_item_location.position.x) * direction
		collision_shape_2d.position.x = abs(collision_shape_2d.position.x) * direction
	
	# Animations
	if is_on_floor():
		if input == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jumping")
		
	# Velocity
	if input:
		velocity.x = input * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	
func process_dead(delta):
	velocity.y += gravity * delta
	velocity.x = 0.0
	animated_sprite.play("death")
	move_and_slide()

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		if held_crate:
			throw_crate()
		else:
			try_pickup_crate()

func throw_crate():
	var crate: Crate = held_crate
	
	held_crate.get_parent().remove_child(held_crate)
	held_crate = null
	get_tree().current_scene.add_child(crate)
	crate.global_position = held_item_location.global_position
	crate.set_thrown_state(direction)

func try_pickup_crate():
	var crates = pickup_area.get_overlapping_bodies()
	var closest: Crate = null
	var closest_dist := INF
	
	for body in crates:
		if body is Crate and body.state == Crate.CrateState.IDLE:
			var dist = global_position.distance_to(body.global_position)
			if dist < closest_dist:
				closest = body
				closest_dist = dist
	
	if closest:
		pickup(closest)

func pickup(crate: Crate):
	var tween = create_tween()
	tween.tween_property(crate, "global_position", held_item_location.global_position, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	crate.set_collision_layer(0)
	crate.set_collision_mask(0)
	
	tween.finished.connect(func():
		crate.get_parent().remove_child(crate)
		held_item_location.add_child(crate)
		crate.position = Vector2.ZERO
		held_crate = crate
		crate.set_held_state()
		)

