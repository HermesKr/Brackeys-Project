class_name Crate extends CharacterBody2D

@onready var hurtbox_area = $HurtboxArea

const DECELERATION = 600
const THROW_FORCE = 350

enum CrateState { IDLE, HELD, THROWN }
var state: CrateState = CrateState.IDLE
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _process(delta):
	if not state == CrateState.HELD:
		velocity.y += gravity * delta
	
	if state == CrateState.THROWN:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
	
	if state == CrateState.THROWN and velocity.length() < 10 and is_on_floor():
		set_idle_state()
	print(velocity.length())
	move_and_slide()

func set_held_state():
	state = CrateState.HELD
	velocity = Vector2.ZERO
	
	hurtbox_area.monitoring = false

func set_idle_state():
	state = CrateState.IDLE
	hurtbox_area.monitoring = false
	velocity = Vector2.ZERO


func set_thrown_state(direction: Vector2):
	state = CrateState.THROWN
	velocity = direction.normalized() * THROW_FORCE
	print(velocity)
	hurtbox_area.monitoring = true
	hurtbox_area.set_collision_mask_value(3, true)
	set_collision_layer(8)
	set_collision_mask(1)

func _on_hurtbox_area_body_entered(body):
	if state == CrateState.THROWN and body.is_in_group("enemy"):
		body.die()
