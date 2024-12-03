extends can_be_damaged

signal show_text(message: String)

var enemies: Array = []
var doors: Array = []
var current_enemy_index: int = -1

@onready var camera = $CameraPivot/Camera3D
# Movement settings
@export var current_enemy: can_be_damaged
@export var casted_on: can_be_damaged

@export var max_interaction_distance = 15
@export var grid_size: float = 5.0  # Size of each grid cell (2x2x2 for your case)
@export var speed: float = 15.0 # Speed of movement (tiles per second)
@export var joystick: VirtualJoystick

var direction: Vector3 = Vector3.ZERO
var target_position: Vector3
var moving: bool = false
var door_in_range
var last_direction

var health_potion_amount = 25
const HEALTH_POT_AMOUNT = 40
const MANA_POT_AMOUNT = 70
var mana_potion_amount = 25
var potion_timer: Timer
var potion_cooldown: bool = false
const POTION_TIMER_WAIT = 12

var mouse_movement := false
var mouse_actions = {
	"up": false,
	"down": false,
	"left": false,
	"right": false,
}

enum Potions {
	MANA,
	HEALTH
}

@rpc("call_local")
func client_setup_player(player_id):
	var self_id = multiplayer.get_unique_id()
	
	var is_player = self_id == player_id
	print("SETTING UP PLAYER")
	set_process(is_player)
	set_physics_process(is_player)
	camera.current = is_player

	# Ensure multiplayer authority is set on the local player
	if is_player:
		set_multiplayer_authority(player_id)

func _ready():
	super._ready()

	potion_timer = Timer.new()
	potion_timer.one_shot = true
	potion_timer.autostart = false
	potion_timer.wait_time = POTION_TIMER_WAIT
	potion_timer.connect("timeout", Callable(self, "_on_potion_refresh"))
	add_child(potion_timer)
	
	global_transform.origin = snap_to_grid(global_transform.origin)
	target_position = global_transform.origin
	last_direction = Vector3.UP

func _physics_process(delta):
	if is_multiplayer_authority():
		if mouse_movement:
			apply_mouse_input()
		handle_movement(delta)

func _on_potion_refresh():
	potion_cooldown = false

func update_direction():
	direction = Vector3.ZERO
	if mouse_actions.right:
		direction.z -= 1
	if mouse_actions.left:
		direction.z += 1
	if mouse_actions.down:
		direction.x += 1
	if mouse_actions.up:
		direction.x -= 1
				
func _handle_8way_input(direction: Vector2) -> void:
	var angle = rad_to_deg(direction.angle())
	angle = fmod(angle + 360.0, 360.0)

	mouse_actions.up = (angle >= 247.5 and angle < 337.5)
	mouse_actions.down = (angle >= 67.5 and angle < 157.5)
	mouse_actions.left = (angle >= 157.5 and angle < 247.5)
	mouse_actions.right = (angle >= 337.5 or angle < 67.5)

	update_direction()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		handle_mouse_event(event)
	elif event.is_action_pressed("toggle_enemy"):
		toggle_enemy()
	elif event.is_action_pressed("open_door"):
		try_open_door()
	elif event.is_action_pressed("mana_potion"):
		handle_drink_potion(Potions.MANA)
	elif event.is_action_pressed("health_potion"):
		handle_drink_potion(Potions.HEALTH)
	else:
		for spell in Global.spelldictionary.keys():
			if InputMap.has_action(spell) and event.is_action_pressed(spell):
				handle_spell_cast(spell)
				break

func handle_drink_potion(potion_type: Potions):
	if potion_cooldown:
		return
		
	match (potion_type):
		Potions.HEALTH:
			if health_potion_amount <= 0:
				return
			health_potion_amount -= 1
			current_health += HEALTH_POT_AMOUNT
		Potions.MANA:
			if mana_potion_amount <= 0:
				return
			mana_potion_amount -= 1
			current_mana += MANA_POT_AMOUNT
			
	potion_cooldown = true
	potion_timer.start()
		

func handle_mouse_event(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			mouse_movement = true
		elif event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			mouse_movement = false
			clear_mouse_actions()

	elif event is InputEventMouseMotion and mouse_movement:
		apply_mouse_input()

func clear_mouse_actions():
	for action in mouse_actions:
		mouse_actions[action] = false
	direction = Vector3.ZERO
	
func apply_mouse_input():
	var camera = get_viewport().get_camera_3d()
	var player_screen_position = camera.unproject_position(global_position)
	var mouse_position = get_viewport().get_mouse_position()
	var vector: Vector2 = (mouse_position - player_screen_position).normalized()
	_handle_8way_input(vector)

func handle_spell_cast(spell):
	var spell_information = Global.spelldictionary[spell]
	if not spell_information.has("self"):
		if not check_line_of_sight(current_enemy, true):
			return

	if not spell_timer.is_stopped():
		spell_timer.stop()

	show_text.emit(spell_information.words_of_power)
	current_spell = spell
	casted_on = current_enemy
	spell_timer.wait_time = spell_information.duration
	casting = true
	spell_timer.start()

func handle_movement(delta):
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		last_direction = -direction
		$Pivot.basis = Basis.looking_at(last_direction)

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

func toggle_enemy() -> void:
	
	var parent = get_parent()
	if not parent:
		return
	
	if enemies.size() == 0:
		enemies.clear()
		for child in parent.get_children():
			if child == self:
				continue
			if child is can_be_damaged:
				enemies.append(child)
		
		enemies.sort_custom(Callable(self, "_compare_enemies")) 
	
	if enemies.size() == 0:
		current_enemy_index = -1
		return
	
	current_enemy_index += 1
	if current_enemy_index >= enemies.size():
		current_enemy_index = 0  # Wrap back to the first enemy
	
	var new_enemy = enemies[current_enemy_index]
	current_enemy.targetted = false
	current_enemy = new_enemy
	current_enemy.targetted = true

func _compare_enemies(a: Node, b: Node) -> int:
	return a.get_instance_id() < b.get_instance_id()

func try_open_door():
	if (door_in_range):
		door_in_range.toggle_open()
