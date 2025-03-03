extends CanvasLayer

var action_list = []
var button_container
var currently_remapping = null

func _ready():
	button_container = $ScrollContainer/VBoxContainer

	action_list = InputMap.get_actions()
	action_list.sort()
	
	var filtered_actions = []
	for action in action_list:
		if action.begins_with("move_") or action in ["flamestrike", "lightning", "poison", "spark", "cure"]:
			filtered_actions.append(action)
	
	for action in filtered_actions:
		create_action_button(action)

func create_action_button(action_name):
	var hbox = HBoxContainer.new()
	
	var label = Label.new()
	label.text = format_action_name(action_name)
	#label.size_flags_horizontal = Control.SIZE_FLAGS_EXPAND_FILL
	
	var button = Button.new()
	button.text = get_action_key_text(action_name)
	#button.size_flags_horizontal = Control.SIZE_FLAGS_EXPAND_FILL
	
	button.pressed.connect(_on_remap_button_pressed.bind(action_name, button))
	
	hbox.add_child(label)
	hbox.add_child(button)
	
	button_container.add_child(hbox)

func format_action_name(action_name):
	var words = action_name.split("_")
	for i in range(words.size()):
		words[i] = words[i].capitalize()
	return " ".join(words)

func get_action_key_text(action_name):
	var events = InputMap.action_get_events(action_name)
	if events.size() > 0:
		var event = events[0]
		if event is InputEventKey:
			return OS.get_keycode_string(event.keycode)
	
	return "Unassigned"

func _on_remap_button_pressed(action_name, button):
	
	button.text = "Press any key..."
	currently_remapping = {"action": action_name, "button": button}
	
	set_process_input(true)

func _input(event):
	if currently_remapping != null:
		if event is InputEventKey and event.pressed and not event.echo:
			var action = currently_remapping.action
			InputMap.action_erase_events(action)
			
			InputMap.action_add_event(action, event)
			currently_remapping.button.text = OS.get_keycode_string(event.keycode)
			
			save_input_mapping()
			
			# Reset the remapping state
			currently_remapping = null
			set_process_input(false)
			
			get_tree().set_input_as_handled()

func save_input_mapping():
	var mappings = {}
	
	for action in action_list:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			var event = events[0]
			if event is InputEventKey:
				mappings[action] = event.keycode
	
	var config = ConfigFile.new()
	config.set_value("input", "mappings", mappings)
	config.save("user://input_mappings.cfg")

func load_input_mapping():
	var config = ConfigFile.new()
	var err = config.load("user://input_mappings.cfg")
	
	if err == OK:
		var mappings = config.get_value("input", "mappings", {})
		
		for action in mappings.keys():
			var keycode = mappings[action]
			
			InputMap.action_erase_events(action)
			
			var event = InputEventKey.new()
			event.keycode = keycode
			InputMap.action_add_event(action, event)
