extends can_be_damaged

signal show_text(message: String)

var enemies: Array = []
var current_enemy_index: int = -1

@onready var camera = $CameraPivot/Camera3D
@onready var world = get_parent().get_parent()
@onready var anim_player = $Pivot/Mage/AnimationPlayer
@onready var input_control = $InputControl

@export var current_enemy: int
@export var casted_on: int
@export var max_interaction_distance = 15
@export var grid_size: float = 2.0  # Size of each grid cell (2x2x2 for your case)
@export var speed: float = 15.0 # Speed of movement (tiles per second)
@export var joystick: VirtualJoystick
@export var potion_cooldown: bool = false

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
const POTION_TIMER_WAIT = 12

enum Potions {
	MANA,
	HEALTH
}

enum Resources {
	MANA,
	HEALTH
}

@rpc("any_peer")
func update_direction(new_direction):
	direction = new_direction

@rpc("any_peer", "call_local")
func setup_multiplayer(player_id):
	var self_id = multiplayer.get_unique_id()
	var is_player = self_id == player_id
	if is_player:
		camera.current = is_player

	set_physics_process(multiplayer.is_server())

func _ready():
	await get_tree().create_timer(0.5).timeout
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
	if not multiplayer.is_server():
		return
	handle_movement(delta)

func _on_potion_refresh():
	potion_cooldown = false

@rpc("any_peer", "call_local")
func handle_drink_potion(potion_type: Potions):
	if potion_cooldown:
		return

	var player = Global.active_players[str(multiplayer.get_remote_sender_id())]
	match (potion_type):
		Potions.HEALTH:
			if health_potion_amount <= 0:
				return
			health_potion_amount -= 1
			player.current_health += clamp(HEALTH_POT_AMOUNT, 0, max_health)
		Potions.MANA:
			if mana_potion_amount <= 0:
				return
			mana_potion_amount -= 1
			player.current_mana = clamp(current_mana + MANA_POT_AMOUNT, 0, max_mana)

	potion_cooldown = true
	potion_timer.start()

@rpc("any_peer", "call_local")
func sync_potion_timer_status(is_stopped: bool, time_left: float):
	potion_cooldown = not is_stopped
	if not is_stopped:
		potion_timer.start(time_left)

@rpc("any_peer", "call_local")
func show_player_text(message):
	show_text.emit(message)

@rpc("any_peer", "call_local")
func handle_spell_cast(spell):
	if not current_enemy:
		print("No Current Enemy...")
		return

	var spell_information = Global.spelldictionary[spell]
	if not spell_information.has("self"):
		var caster = multiplayer.get_remote_sender_id()
		rpc_id(1, "check_spell_can_cast", caster, current_enemy, spell)

func handle_movement(_delta):
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		last_direction = -direction
		$Pivot.basis = Basis.looking_at(last_direction)

		var intended_position = global_transform.origin + direction * grid_size
		target_position = snap_to_grid(intended_position)

		velocity = direction * speed

		if (anim_player.current_animation != "Running_A"):
			print(name, " is running")
			rpc("handle_player_anim", "Running_A")

		# Slightly more lenient movement check
		if global_transform.origin.distance_to(target_position) >= grid_size * 0.1:
			moving = true
			move_and_slide()
		else:
			velocity = direction * speed
			move_and_slide()
	else:
		velocity = Vector3.ZERO
		if (anim_player.current_animation != "Idle"):
			rpc("handle_player_anim", "Idle")
		moving = false

@rpc("any_peer")
func handle_player_anim(animation_name):
	anim_player.play(animation_name)

func snap_to_grid(new_position: Vector3) -> Vector3:
	# Ensure the position is aligned to grid steps (rounds to nearest grid step)
	return Vector3(
		round(new_position.x / grid_size) * grid_size,
		0,
		round(new_position.z / grid_size) * grid_size
	)

func can_move_to(new_position: Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	var ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.from = global_transform.origin
	ray_params.to = new_position
	ray_params.collide_with_bodies = true
	ray_params.exclude = [self]
	return space_state.intersect_ray(ray_params).is_empty()

@rpc("authority")
func check_line_of_sight(start, end) -> bool:
	var space_state = get_world_3d().direct_space_state
	var ray_params = PhysicsRayQueryParameters3D.new()

	var start_node = Global.active_players[str(start)]
	var end_node = Global.active_players[str(end)]
	ray_params.exclude = [start_node]
	ray_params.from = start_node.global_transform.origin
	ray_params.to = end_node.global_transform.origin
	var result = space_state.intersect_ray(ray_params)

	if result:
		#DrawLine.DrawLine(ray_params.from, result.position, Color(0, 0, 1), 1.5)
		if (result.collider == end_node):
			return true

	return false

func is_dead():
	return current_health <= 0

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
		rpc_id(1, "check_spell_landed", target, current_spell)
		return
	else:
		rpc_id(1, "authorised_cast", true, name, current_spell)



@rpc("any_peer", "call_local")
func authorised_cast(allowed: bool, target, spell):
	if multiplayer.get_remote_sender_id() == 1:
		if allowed:
			if not spell_timer.is_stopped():
				spell_timer.stop()

			var spell_information = Global.spelldictionary[spell]
			show_text.emit(spell_information.words_of_power)
			current_spell = spell
			casted_on = target
			spell_timer.wait_time = spell_information.duration
			casting = true
			spell_timer.start()
		else:
			print("Not in LOS")

@rpc("authority", "call_local")
func check_spell_can_cast(caster, target, spell):
	var spell_hit = check_line_of_sight(caster, target)
	rpc_id(multiplayer.get_remote_sender_id(), "authorised_cast", spell_hit, target, spell)


@rpc("authority", "call_local")
func check_spell_landed(target, spell):
	var spell_information = Global.spelldictionary[spell]
	var caster = int(str(name))
	var spell_hit = check_line_of_sight(caster, target)
	if spell_hit:

		if spell == "poison" and Global.active_players[str(target)].poisoned == false:
			Global.active_players[str(target)].poisoned = true
			Global.active_players[str(target)].poison_timer.start()

		if spell == "cure":
			poisoned = false
			poison_timer.stop()

		rpc("show_effect", target, spell)
		Global.active_players[str(target)].current_health -= spell_information.damage
		if Global.active_players[str(target)].current_health <= 0:
			rpc("handle_player_death", target)
			world.rpc_id(target, "show_death_menu")
			Global.active_players[str(target)].set_physics_process(false)
		Global.active_players[str(caster)].current_mana -= spell_information.cost
	else:
		print("SPELL MISSED")
	pass

@rpc("authority", "call_remote", "reliable", 2)
func handle_player_death(player_id):
	var parent = get_parent()
	var character = parent.get_node_or_null(str(player_id))
	if character:
		character.anim_player.play("Death_B")
		set_process(false)
		set_physics_process(false)

@rpc("any_peer", "call_local")
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

	current_enemy = int(str(enemies[current_enemy_index].name))

func _compare_enemies(a: Node, b: Node) -> int:
	return a.get_instance_id() < b.get_instance_id()

func try_open_door():
	if (door_in_range):
		var door_node = get_node_or_null(door_in_range)
		if door_node:
			door_node.rpc_id(1, "toggle_open")
