extends CharacterBody3D

# Movement settings
@export var speed: float = 0.1  # Movement speed (tiles per second)
@export var grid_size: float = 2.0  # Size of each grid cell
var target_position: Vector3  # Target position the player will move towards
var moving: bool = false  # Whether the character is currently moving
var direction: Vector3 = Vector3.ZERO  # Direction of movement
var move_duration: float = 0.0  # Time it takes to move to the next grid cell

func _ready():
	# Snap the starting position to the grid
	target_position = global_transform.origin.snapped(Vector3(grid_size, grid_size, grid_size))

func _physics_process(delta):
	# Handle movement only if the player is not currently moving
	if moving:
		move_duration -= delta

		# Smooth movement towards the target position using lerp
		global_transform.origin = global_transform.origin.lerp(target_position, 1 - (move_duration / speed))

		# If we've reached the target position, stop moving
		if move_duration <= 0:
			global_transform.origin = target_position
			moving = false

	# Handle input when the player is not moving
	if not moving:
		direction = Vector3.ZERO  # Reset direction

		# Capture movement input
		if Input.is_action_pressed("move_right"):
			direction.x += 1
		elif Input.is_action_pressed("move_left"):
			direction.x -= 1
		elif Input.is_action_pressed("move_back"):
			direction.z += 1
		elif Input.is_action_pressed("move_forward"):
			direction.z -= 1

		# If there is movement input, calculate the target position
		if direction != Vector3.ZERO:
			# Move exactly one grid cell forward/back/left/right
			var intended_position = global_transform.origin + direction * grid_size

			# Snap the intended position to the grid to maintain consistency
			intended_position = intended_position.snapped(Vector3(grid_size, grid_size, grid_size))

			# Check for collisions before moving
			if can_move_to(intended_position):
				moving = true
				target_position = intended_position

				# Set move duration to be the speed, to ensure consistent movement time
				move_duration = speed

				# Play running animation
				$Pivot/Mage/AnimationPlayer.play("Running_A")

				# Update rotation to face movement direction
				var flipped = -direction
				$Pivot.basis = Basis.looking_at(flipped)
			else:
				$Pivot/Mage/AnimationPlayer.play("Idle")  # Stay idle if blocked
		else:
			# Play idle animation if no movement direction
			$Pivot/Mage/AnimationPlayer.play("Idle")

	# Apply movement only along the x and z axes
	velocity.x = direction.x * speed  # Apply horizontal movement (x-axis)
	velocity.z = direction.z * speed  # Apply horizontal movement (z-axis)

	# Use move_and_slide() to move the character
	move_and_slide()

# Collision check function
func can_move_to(position: Vector3) -> bool:
	# Perform a collision check at the intended position
	var space_state = get_world_3d().direct_space_state

	# Create a PhysicsRayQueryParameters3D object
	var ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.from = global_transform.origin
	ray_params.to = position
	ray_params.collide_with_areas = true
	ray_params.collide_with_bodies = true
	ray_params.exclude = [self]  # Exclude the player itself from the raycast

	# Perform the raycast
	var collision = space_state.intersect_ray(ray_params)

	# Return true if no collision was detected
	return collision.is_empty()
