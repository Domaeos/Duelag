extends Control

@onready var parent = get_parent()
var mouse_movement := false
var mouse_actions = {
	"up": false,
	"down": false,
	"left": false,
	"right": false,
}
var direction: Vector3

@rpc("any_peer", "call_local")
func setup_multiplayer(player_id):
	var self_id = multiplayer.get_unique_id()
	var is_player = self_id == player_id
	if is_player:
		print("Setting up input node for: ", player_id)
	set_process(is_player)
	set_process_input(is_player)

func _process(delta: float) -> void:
	if mouse_movement:
		apply_mouse_input()

func apply_mouse_input():
	var player_screen_position = parent.camera.unproject_position(parent.global_position)
	var mouse_position = get_viewport().get_mouse_position()
	var vector: Vector2 = (mouse_position - player_screen_position).normalized()
	handle_8way_input(vector)

func handle_8way_input(new_direction: Vector2) -> void:
	var angle = rad_to_deg(new_direction.angle())
	angle = fmod(angle + 360.0, 360.0)  # Normalize angle to 0–360
	
	# Clear all actions first
	mouse_actions.up = false
	mouse_actions.down = false
	mouse_actions.left = false
	mouse_actions.right = false
	
	# Set directions based on angle
	if angle >= 247.5 and angle < 292.5:  # Up
		mouse_actions.up = true
	elif angle >= 292.5 and angle < 337.5:  # Up-right
		mouse_actions.up = true
		mouse_actions.right = true
	elif angle >= 337.5 or angle < 22.5:  # Right
		mouse_actions.right = true
	elif angle >= 22.5 and angle < 67.5:  # Down-right
		mouse_actions.right = true
		mouse_actions.down = true
	elif angle >= 67.5 and angle < 112.5:  # Down
		mouse_actions.down = true
	elif angle >= 112.5 and angle < 157.5:  # Down-left
		mouse_actions.down = true
		mouse_actions.left = true
	elif angle >= 157.5 and angle < 202.5:  # Left
		mouse_actions.left = true
	elif angle >= 202.5 and angle < 247.5:  # Up-left
		mouse_actions.left = true
		mouse_actions.up = true
	
	calculate_direction()

func calculate_direction():
	direction = Vector3.ZERO
	if mouse_actions.right:
		direction.z -= 1
	if mouse_actions.left:
		direction.z += 1
	if mouse_actions.down:
		direction.x += 1
	if mouse_actions.up:
		direction.x -= 1

	if direction != parent.direction:
		parent.rpc_id(1, "update_direction", direction)

func _input(event: InputEvent) -> void:
	if parent.is_dead():
		return

	if event is InputEventMouseMotion or event is InputEventMouseButton:
		handle_mouse_event(event)
	elif event.is_action_pressed("toggle_enemy"):
		parent.rpc_id(1, "toggle_enemy")
	elif event.is_action_pressed("open_door"):
		parent.rpc_id(1, "try_open_door")
	elif event.is_action_pressed("mana_potion"):
		parent.rpc_id(1, "handle_drink_potion", parent.Potions.MANA)
	elif event.is_action_pressed("health_potion"):
		parent.rpc_id(1, "handle_drink_potion", parent.Potions.HEALTH)
	else:
		for spell in Global.spelldictionary.keys():
			if InputMap.has_action(spell) and event.is_action_pressed(spell):
				parent.rpc_id(1, "handle_spell_cast", spell)
				break

func clear_mouse_actions():
	for action in mouse_actions:
		mouse_actions[action] = false
	parent.rpc_id(1, "update_direction", Vector3.ZERO)

func handle_mouse_event(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			mouse_movement = true
		elif event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			mouse_movement = false
			clear_mouse_actions()
	elif event is InputEventMouseMotion and mouse_movement:
		apply_mouse_input()
