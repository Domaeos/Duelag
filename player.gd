extends can_be_damaged

signal show_text(message: String)

var enemies: Array = []  # List of all enemies
var current_enemy_index: int = -1  # Index of the current enemy, starts at -1 (none selected)

# Movement settings
@export var casting: String
@export var current_mana: float = 100.0
@export var current_enemy: can_be_damaged
@export var casted_on: can_be_damaged

@export var grid_size: float = 2.0  # Size of each grid cell (2x2x2 for your case)
@export var speed: float = 15.0 # Speed of movement (tiles per second)

var direction: Vector3 = Vector3.ZERO
var target_position: Vector3
var moving: bool = false

func _ready():
	super._ready()
	# Snap the player's initial position to the center of the grid
	global_transform.origin = snap_to_grid(global_transform.origin)
	target_position = global_transform.origin

func _physics_process(delta):
	# Reset direction at the start of each frame
	direction = Vector3.ZERO
	handle_input()
	handle_movement(delta)

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

	if (Input.is_action_just_pressed("toggle_enemy")):
		toggle_enemy()
		return
	
	for spell in Global.spelldictionary.keys():
		if (Input.is_action_just_pressed(spell)):
			var spell_information = Global.spelldictionary[spell]
			
			if spell_information.has("self") == false:
				var in_line_of_sight = check_line_of_sight(current_enemy, true)
				if not in_line_of_sight:
					print("Not in LOS")
					return
				
			if $SpellTimer.is_stopped() == false:
				$SpellTimer.stop()
				print("Fizzled self")
				show_text.emit("Self fizzled")
		
			show_text.emit(spell_information.words_of_power)
			casting = spell
			casted_on = current_enemy
			$SpellTimer.wait_time = spell_information.duration
			$SpellTimer.start()
			break

func handle_movement(delta):
	if direction != Vector3.ZERO:
		direction = direction.normalized()

		# Calculate the movement target (move by grid_size steps)
		var intended_position = global_transform.origin + direction * grid_size
		target_position = snap_to_grid(intended_position)

		# Set velocity to move the player at the desired speed
		velocity = direction * speed

		# Play running animation while moving
		$Pivot/Mage/AnimationPlayer.play("Running_A")

		# Move towards target position if distance is greater than a threshold
		if global_transform.origin.distance_to(target_position) > 0.1:
			moving = true
		else:
			# Stop movement once the target is reached
			moving = false
			velocity = Vector3.ZERO
			$Pivot/Mage/AnimationPlayer.play("Idle")

	# If moving, apply velocity to move the player
	if moving:
		# Move using velocity and update position smoothly
		move_and_slide()  # This now uses the built-in velocity

		# Update rotation to face movement direction
		var flipped_direction = -direction
		$Pivot.basis = Basis.looking_at(flipped_direction)

	# If no input and not moving, stop animation and reset velocity
	if direction == Vector3.ZERO:
		# Ensure the player stops by resetting velocity
		velocity = Vector3.ZERO
		$Pivot/Mage/AnimationPlayer.play("Idle")
		moving = false  # Stop movement entirely

func snap_to_grid(position: Vector3) -> Vector3:
	# Ensure the position is aligned to grid steps (rounds to nearest grid step)
	return Vector3(
		round(position.x / grid_size) * grid_size,
		round(position.y / grid_size) * grid_size,
		round(position.z / grid_size) * grid_size
	)

func can_move_to(new_position: Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	var ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.from = global_transform.origin
	ray_params.to = new_position
	ray_params.collide_with_bodies = true
	ray_params.exclude = [self]
	return space_state.intersect_ray(ray_params).is_empty()

func check_line_of_sight(end: Node3D, initial: bool) -> bool:
	var space_state = get_world_3d().direct_space_state  
	var ray_params = PhysicsRayQueryParameters3D.new()

	ray_params.from = global_transform.origin
	ray_params.to = end.global_transform.origin
	var result = space_state.intersect_ray(ray_params)
	
	if result:
		DrawLine.DrawLine(ray_params.from, result.position, Color(0, 0, 1), 1.5)
		if (initial == true):
			if (result.collider == current_enemy):
				return true
		else:
			if (result.collider == casted_on):
				return true
	return false
	
func _on_spell_timeout() -> void:
	var target = self
	var spell_information = Global.spelldictionary[casting]
	if spell_information.has("self") == false:
		target = casted_on
		var in_line_of_sight = check_line_of_sight(target, false)
		print("Casted on: ", target, "LOS?: ", in_line_of_sight)
		if !in_line_of_sight:
			print("LOS BROKEN")
			return
			
	target.spell_landed(casting)
	current_mana -= spell_information.cost
	print(casting + " has finished casting on " + target.name)

func toggle_enemy() -> void:
	print("Toggling enemies")
	
	# Get the parent node (root of the player's scene)
	var parent = get_parent()
	if not parent:
		print("No parent found for player")
		return
	
	# Populate the list of enemies if it's empty
	if enemies.size() == 0:  # Corrected from `empty()`
		enemies.clear()  # Reset the enemies array
		for child in parent.get_children():
			# Skip the player itself
			if child == self:
				continue
			# Add valid enemies (instances of can_be_damaged) to the list
			if child is can_be_damaged:
				enemies.append(child)
		
		# Sort the enemies array (optional, e.g., by position or name for consistent ordering)
		enemies.sort_custom(Callable(self, "_compare_enemies"))  # Corrected sort_custom usage
	
	# Handle case where no enemies were found
	if enemies.size() == 0:
		print("No enemies found")
		current_enemy_index = -1
		return
	
	# Increment the index to the next enemy
	current_enemy_index += 1
	if current_enemy_index >= enemies.size():
		current_enemy_index = 0  # Wrap back to the first enemy
	
	# Select the new enemy
	var new_enemy = enemies[current_enemy_index]
	current_enemy.targetted = false
	current_enemy = new_enemy
	current_enemy.targetted = true

# Example comparison function for sorting enemies
func _compare_enemies(a: Node, b: Node) -> int:
	# Compare based on unique instance ID
	return a.get_instance_id() < b.get_instance_id()
