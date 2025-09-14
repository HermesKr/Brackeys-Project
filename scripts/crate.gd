class_name Crate extends CharacterBody2D

@onready var hurtbox_area = $HurtboxArea

const THROW_SPEED_X = 400
const THROW_SPEED_Y = -150
const DECELERATION = 600

enum CrateState { IDLE, HELD, THROWN }
var state: CrateState = CrateState.IDLE
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _process(delta):
	if not state == CrateState.HELD:
		velocity.y += gravity * delta
	
	if state == CrateState.THROWN:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
	
	if state == CrateState.THROWN and abs(velocity.x) < 5:
		set_idle_state()
	
	move_and_slide()

func set_held_state():
	state = CrateState.HELD
	velocity = Vector2.ZERO
	
	# the environment layer is 1
	hurtbox_area.monitoring = false

func set_idle_state():
	state = CrateState.IDLE
	hurtbox_area.monitoring = false
	velocity = Vector2.ZERO

func set_thrown_state(direction: int):
	state = CrateState.THROWN
	velocity = Vector2(THROW_SPEED_X * direction, THROW_SPEED_Y)
	hurtbox_area.monitoring = true
	hurtbox_area.set_collision_mask_value(3, true)
	set_collision_layer(8)
	set_collision_mask(1)


func _on_hurtbox_area_body_entered(body):
	print("ouch!")
	if state == CrateState.THROWN and body.is_in_group("enemy"):
		body.die()
