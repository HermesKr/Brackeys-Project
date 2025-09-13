extends CharacterBody2D

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_ledge_right = $RayCastLedgeRight
@onready var ray_cast_ledge_left = $RayCastLedgeLeft
@onready var animated_sprite = $AnimatedSprite2D

const SPEED = 60
const DEACTIVATE_RAYCAST_TIMER = 0.1
const HAZARD_CHECK_INTERVAL = 0.05

var direction = 1
var ledge_check_enabled := true
var hazard_check_timer = 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	hazard_check_timer -= delta
	if hazard_check_timer <= 0:
		check_for_hazards()
		hazard_check_timer = HAZARD_CHECK_INTERVAL
	
	position.x += SPEED * delta * direction
	move_and_slide()

func check_for_hazards():
	if ledge_check_enabled:
		if ray_cast_right.is_colliding():
			flip_direction()
		if ray_cast_left.is_colliding():
			flip_direction()
		if !ray_cast_ledge_left.is_colliding():
			flip_direction()
		if !ray_cast_ledge_right.is_colliding():
			flip_direction()

func flip_direction():
	direction = direction * -1
	animated_sprite.flip_h = !animated_sprite.flip_h
	ledge_check_enabled = false
	await get_tree().create_timer(DEACTIVATE_RAYCAST_TIMER).timeout
	ledge_check_enabled = true
