extends CharacterBody3D

# Movement settings
@export var speed = 30  # Movement speed
@export var grid_size: float = 1.0  # Size of each grid cell
@export var fall_acceleration = 75  # Gravity effect when falling

var target_position: Vector3
var moving: bool = false  # Whether the character is currently moving

func _ready():
	# Snap the starting position to the grid
	target_position = global_transform.origin.snapped(Vector3(grid_size, grid_size, grid_size))

func _physics_process(delta):
	if moving:
		# Smoothly move toward the target position
		var current_position = global_transform.origin
		global_transform.origin = current_position.lerp(target_position, speed * delta)

		# Check if we've reached the target position
		if current_position.distance_to(target_position) < 0.01:
			global_transform.origin = target_position
			moving = false

	# Handle input only when not moving
	if not moving:
		var direction = Vector3.ZERO

		if Input.is_action_pressed("move_right"):
			direction.x += 1
		elif Input.is_action_pressed("move_left"):
			direction.x -= 1
		elif Input.is_action_pressed("move_back"):
			direction.z += 1
		elif Input.is_action_pressed("move_forward"):
			direction.z -= 1

		if direction != Vector3.ZERO:
			# Calculate the intended target position
			var intended_position = (global_transform.origin + direction * grid_size).snapped(Vector3(grid_size, grid_size, grid_size))

			# Check for collisions before moving
			if can_move_to(intended_position):
				moving = true
				target_position = intended_position

				# Play running animation
				$Pivot/Mage/AnimationPlayer.play("Running_A")

				# Update rotation to face movement direction
				var flipped = -direction
				$Pivot.basis = Basis.looking_at(flipped)
			else:
				$Pivot/Mage/AnimationPlayer.play("Idle")  # Stay idle if blocked
		else:
			# Play idle animation
			$Pivot/Mage/AnimationPlayer.play("Idle")
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
