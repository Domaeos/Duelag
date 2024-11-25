extends can_be_damaged

signal show_text(message: String)

var enemies: Array = []
var doors: Array = []
var current_enemy_index: int = -1

# Movement settings
@export var current_enemy: can_be_damaged
@export var casted_on: can_be_damaged

@export var max_interaction_distance = 15
@export var grid_size: float = 2.0  # Size of each grid cell (2x2x2 for your case)
@export var speed: float = 15.0 # Speed of movement (tiles per second)
@export var joystick: VirtualJoystick

var direction: Vector3 = Vector3.ZERO
var target_position: Vector3
var moving: bool = false
var door_in_range
var last_direction

var mouse_movement := false
var mouse_actions = {
	"up": false,
	"down": false,
	"left": false,
	"right": false,
}

func _ready():
	super._ready()
	joystick = $"Control/CanvasLayer/Virtual Joystick"
	# Snap the player's initial position to the center of the grid
	global_transform.origin = snap_to_grid(global_transform.origin)
	target_position = global_transform.origin
	last_direction = Vector3.UP

func _physics_process(delta):
	# Reset direction at the start of each frame
	direction = Vector3.ZERO
	handle_input()
	handle_movement(delta)
	if (mouse_movement):
		print(mouse_actions)

func handle_mouse_press():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			mouse_movement = true
			var player_3d_position = global_position
			var camera = get_viewport().get_camera_3d()
			var mouse_positon = get_viewport().get_mouse_position()
			var player_screen_position = camera.unproject_position(player_3d_position)
			var vector : Vector2 = (mouse_positon - player_screen_position).normalized()
			_handle_8way_input(vector)
	else:
			mouse_movement = false
			for action in mouse_actions:
				action = false
	
func _handle_8way_input(direction: Vector2) -> void:
	var angle = rad_to_deg(direction.angle())
	angle = fmod(angle + 360.0, 360.0)
	
	# Determine which directions to activate based on the angle
	var press_up = false
	var press_down = false
	var press_left = false
	var press_right = false
	
	# Adjusted for the rotated perspective
	if angle >= 337.5 or angle < 22.5:
		press_right = true  # Originally "up"
	elif angle >= 22.5 and angle < 67.5:
		press_right = true  # Originally "up"
		press_down = true  # Originally "right"
	elif angle >= 67.5 and angle < 112.5:
		press_down = true  # Originally "right"
	elif angle >= 112.5 and angle < 157.5:
		press_down = true  # Originally "right"
		press_left = true  # Originally "down"
	elif angle >= 157.5 and angle < 202.5:
		press_left = true  # Originally "down"
	elif angle >= 202.5 and angle < 247.5:
		press_left = true  # Originally "down"
		press_up = true  # Originally "left"
	elif angle >= 247.5 and angle < 292.5:
		press_up = true  # Originally "left"
	elif angle >= 292.5 and angle < 337.5:
		press_up = true  # Originally "left"
		press_right = true  # Originally "up"
	
	# Apply the correct input actions
	mouse_actions.up = press_up
	mouse_actions.down = press_down
	mouse_actions.left = press_left
	mouse_actions.right = press_right

func handle_input():
	handle_mouse_press()
	if not mouse_movement:
		if Input.is_action_pressed("move_right"):
			direction.z -= 1
		if Input.is_action_pressed("move_left"):
			direction.z += 1
		if Input.is_action_pressed("move_down"):
			direction.x += 1
		if Input.is_action_pressed("move_up"):
			direction.x -= 1
	else:
		if mouse_actions.right:
			direction.z -= 1
		if mouse_actions.left:
			direction.z += 1
		if mouse_actions.down:
			direction.x += 1
		if mouse_actions.up:
			direction.x -= 1
	
	if (Input.is_action_just_pressed("toggle_enemy")):
		toggle_enemy()
		return
	
	if (Input.is_action_just_pressed("open_door")):
		try_open_door()
	
	for spell in Global.spelldictionary.keys():
		if InputMap.has_action(spell):
			if (Input.is_action_just_pressed(spell)):
				var spell_information = Global.spelldictionary[spell]
				
				if spell_information.has("self") == false:
					var in_line_of_sight = check_line_of_sight(current_enemy, true)
					if not in_line_of_sight:
						print("Not in LOS")
						return
					
				if spell_timer.is_stopped() == false:
					spell_timer.stop()
					print("Fizzled self")
					show_text.emit("Self fizzled")
			
				show_text.emit(spell_information.words_of_power)
				current_spell = spell
				casted_on = current_enemy
				spell_timer.wait_time = spell_information.duration
				casting = true
				spell_timer.start()
				break

func handle_movement(delta):
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		last_direction = -direction

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

	if moving:
		move_and_slide()

	if direction == Vector3.ZERO:
		# Ensure the player stops by resetting velocity
		velocity = Vector3.ZERO
		$Pivot/Mage/AnimationPlayer.play("Idle")
		moving = false  # Stop movement entirely

	$Pivot.basis = Basis.looking_at(last_direction)
	
	
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

	ray_params.exclude = [self]
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
	casting = false
	if fizzled:
		show_text.emit("Spell fizzled")
		fizzled = false
		return
	
	var target = self
	var spell_information = Global.spelldictionary[current_spell]
	if spell_information.has("self") == false:
		target = casted_on
		var in_line_of_sight = check_line_of_sight(target, false)
		if !in_line_of_sight:
			return
			
	target.spell_landed(current_spell)
	current_mana -= spell_information.cost
	print(current_spell + " has finished casting on " + target.name)

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

func _compare_enemies(a: Node, b: Node) -> int:
	# Compare based on unique instance ID
	return a.get_instance_id() < b.get_instance_id()

func try_open_door():
	if (door_in_range):
		door_in_range.toggle_open()
