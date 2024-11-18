extends can_be_damaged

signal show_text(message: String)

# Movement settings
@export var casting: String
@export var current_enemy: can_be_damaged

@export var grid_size: float = 2.0  # Size of each grid cell
@export var speed: float = 15.0 # Speed of movement (tiles per second)

var direction: Vector3 = Vector3.ZERO
var target_position: Vector3
var moving: bool = false  # Whether the player is currently moving

func _ready():
	# Snap the player's initial position to the center of the grid
	global_transform.origin = snap_to_grid(global_transform.origin)
	target_position = global_transform.origin

func _physics_process(delta):
	# Reset direction at the start of each frame
	direction = Vector3.ZERO
	handle_input()
	# If there is any movement direction, normalize it to avoid faster diagonal movement
	handle_movement()

func handle_input():
	# Handle input for movement (supporting 8 directions)
	if Input.is_action_pressed("move_right"):
		direction.z -= 1
	if Input.is_action_pressed("move_left"):
		direction.z += 1
	if Input.is_action_pressed("move_down"):
		direction.x += 1
	if Input.is_action_pressed("move_up"):
		direction.x -= 1

	if Input.is_action_just_pressed("flamestrike"):
		show_text.emit("Kal Vas Flam")
		$SpellTimer.wait_time = 3.5
		$SpellTimer.start()

func handle_movement():
	if direction != Vector3.ZERO:
		direction = direction.normalized()

		# Set the target position (target grid center)
		var intended_position = global_transform.origin + direction * grid_size
		target_position = snap_to_grid(intended_position)

		# Set velocity to move the player at the desired speed
		velocity = direction * speed

		# Move towards target position if distance is greater than a threshold
		if global_transform.origin.distance_to(target_position) > 0.1:
			moving = true
		else:
			# Stop movement once the target is reached
			moving = false
			velocity = Vector3.ZERO
			$Pivot/Mage/AnimationPlayer.play("Idle")

		# Play running animation while moving
		$Pivot/Mage/AnimationPlayer.play("Running_A")

	# If moving, apply velocity to move the player
	if moving:
		# Move using velocity
		move_and_slide()  # No arguments needed

		# Update rotation to face movement direction
		var flipped_direction = -direction
		$Pivot.basis = Basis.looking_at(flipped_direction)

	# If no input and not moving, stop animation and reset velocity
	if direction == Vector3.ZERO:
		# Ensure the player stops by resetting velocity
		velocity = Vector3.ZERO
		$Pivot/Mage/AnimationPlayer.play("Idle")
		moving = false  # Stop movement entirely

# Snap to the center of the grid cell
func snap_to_grid(position: Vector3) -> Vector3:
	return Vector3(
		floor(position.x / grid_size + 0.5) * grid_size,
		floor(position.y / grid_size + 0.5) * grid_size,
		floor(position.z / grid_size + 0.5) * grid_size
	)

# Check for collisions
func can_move_to(new_position: Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	var ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.from = global_transform.origin
	ray_params.to = new_position
	ray_params.collide_with_bodies = true
	ray_params.exclude = [self]
	return space_state.intersect_ray(ray_params).is_empty()

func _on_spell_timeout() -> void:
	show_text.emit("BAM")
	print(casting + " has finished casting on " + current_enemy.name)
