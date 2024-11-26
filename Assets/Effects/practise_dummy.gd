extends can_be_damaged

@export var player: can_be_damaged

signal show_text(message: String)

var health_bar: ProgressBar
var spell_information: Dictionary
var wait_timer: Timer
var init = false

func _ready() -> void:
	super._ready()
	
	wait_timer = Timer.new()
	wait_timer.wait_time = 1.0
	wait_timer.autostart = false
	wait_timer.one_shot = true
	wait_timer.connect("timeout", Callable(self, "_on_wait_end"))

	add_child(wait_timer)
	global_transform.origin = snap_to_grid()
	
	health_bar = $HealthBar/SubViewport/HealthBar
	if health_bar == null:
		return

	health_bar.max_value = max_health  # Ensure the ProgressBar has a max value
	health_bar.value = current_health  # Set the current value
	

func _process(_delta: float) -> void:
	if init == false:
		init = true
		wait_timer.start()

	if health_bar == null:
		return
		
	if targetted != true:
		health_bar.hide()
	else:
		health_bar.show()
	
		
func _on_wait_end():
	attack_player()

func attack_player():
	while true:
		spell_information = get_random_spell()
		if spell_information.has("self") == false:
			break
	var player_in_los = check_line_of_sight(player)
	if player_in_los:
		fizzled = false
		casting = true
		show_text.emit(spell_information.words_of_power)
		spell_timer.wait_time = spell_information.duration
		spell_timer.start()
		return
		
	casting = false
	wait_timer.start()

func snap_to_grid() -> Vector3:
	# Ensure the position is aligned to grid steps (rounds to nearest grid step)
	return Vector3(
		round(position.x / Global.grid_size) * Global.grid_size,
		round(position.y / Global.grid_size) * Global.grid_size,
		round(position.z / Global.grid_size) * Global.grid_size
	)
func check_line_of_sight(end: Node3D) -> bool:
	var space_state = get_world_3d().direct_space_state  
	var ray_params = PhysicsRayQueryParameters3D.new()
	
	ray_params.from = global_transform.origin
	ray_params.to = end.global_transform.origin

	ray_params.exclude = [self]
	var result = space_state.intersect_ray(ray_params)
	if result:
		DrawLine.DrawLine(ray_params.from, result.position, Color(0, 0, 1), 1.5)
		if result.collider == player:
			return true
	else:
		DrawLine.DrawLine(ray_params.from, ray_params.to, Color(1, 0, 0), 1.5)
	return false

func get_random_spell() -> Dictionary:
	var keys = Global.spelldictionary.keys()
	var random_index = randi() % keys.size()
	var random_key = keys[random_index]
	current_spell = random_key
	return Global.spelldictionary[random_key]


func _on_spell_timeout() -> void:
	if fizzled:
		casting = false
		wait_timer.start()
		return
	
	var spell_information = Global.spelldictionary[current_spell]
	var in_line_of_sight = check_line_of_sight(player)
	
	if in_line_of_sight:
		player.spell_landed(current_spell)
		current_mana -= spell_information.cost
		
	casting = false
	wait_timer.start()
