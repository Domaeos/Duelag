extends CanvasLayer

var action_list = []
var button_container
var currently_remapping = null
var config_file = "user://input_mappings.cfg"
var config = ConfigFile.new()

func _ready():
	# Get reference to container that will hold the buttons
	button_container = $PanelContainer/ScrollContainer/VBoxContainer
	
	# Initialize or load config file
	var err = config.load(config_file)
	if err != OK:
		# If file doesn't exist or can't be loaded, we'll create it on save
		print("No existing config file found, will create on save")
	
	# Get all the defined input actions
	action_list = InputMap.get_actions()
	action_list.sort() # Sort them alphabetically
	
	# Filter out any non-player actions if needed
	var filtered_actions = []
	for action in action_list:
		# You might want to filter out actions that don't need to be remapped
		if action.begins_with("move_") or action in ["flamestrike", "lightning", "poison", "spark", "cure"]:
			filtered_actions.append(action)
	
	# First apply any saved mappings from config
	load_input_mapping()
	
	# Then create UI elements
	for action in filtered_actions:
		create_action_button(action)

func create_action_button(action_name):
	# Create a horizontal container for this action
	var hbox = HBoxContainer.new()
	
	# Add a label with the action name
	var label = Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.text = format_action_name(action_name)
	#label.size_flags_horizontal = Control.SIZE_FLAGS_EXPAND_FILL
	
	# Add a button showing the current key binding (default or from config)
	var button = Button.new()
	button.size_flags_horizontal = Control.SIZE_SHRINK_END
	button.text = get_action_key_text(action_name)
	#button.size_flags_horizontal = Control.SIZE_FLAGS_EXPAND_FILL
	
	# Connect the button to the remapping function
	button.pressed.connect(_on_remap_button_pressed.bind(action_name, button))
	
	# Add components to the container
	hbox.add_child(label)
	hbox.add_child(button)
	
	# Add the horizontal container to the main container
	button_container.add_child(hbox)

func format_action_name(action_name):
	# Convert "move_left" to "Move Left"
	var words = action_name.split("_")
	for i in range(words.size()):
		words[i] = words[i].capitalize()
	return " ".join(words)

func get_action_key_text(action_name):
	# Get the first key assigned to this action
	var events = InputMap.action_get_events(action_name)
	if events.size() > 0:
		var event = events[0]
		if event is InputEventKey:
			return OS.get_keycode_string(event.keycode)
	
	return "Unassigned"

func _on_remap_button_pressed(action_name, button):
	# Visual feedback that we're waiting for input
	button.text = "Press any key..."
	currently_remapping = {"action": action_name, "button": button}
	
	# Start listening for input events
	set_process_input(true)

func _input(event):
	if currently_remapping != null:
		if event is InputEventKey and event.pressed and not event.echo:
			# Remove existing mappings for this action
			var action = currently_remapping.action
			InputMap.action_erase_events(action)
			
			# Add the new mapping
			InputMap.action_add_event(action, event)
			
			# Update the button text
			currently_remapping.button.text = OS.get_keycode_string(event.keycode)
			
			# Save the new mapping
			save_input_mapping()
			
			# Reset the remapping state
			currently_remapping = null
			set_process_input(false)
			
			# Consume the input event
			get_viewport().set_input_as_handled()

func save_input_mapping():
	# Create a dictionary to store the mappings
	var mappings = {}
	
	# Iterate through all actions and store their events
	for action in action_list:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			var event = events[0]
			if event is InputEventKey:
				mappings[action] = event.keycode
	
	# Save the mappings to our already loaded config file
	config.set_value("input", "mappings", mappings)
	config.save(config_file)

func load_input_mapping():
	# Get mappings from our already loaded config
	var mappings = config.get_value("input", "mappings", {})
	
	# Apply the loaded mappings
	for action in mappings.keys():
		# Skip if the action doesn't exist in the InputMap
		if not InputMap.has_action(action):
			continue
			
		var keycode = mappings[action]
		
		# Clear existing mappings
		InputMap.action_erase_events(action)
		
		# Create and add the new event
		var event = InputEventKey.new()
		event.keycode = keycode
		InputMap.action_add_event(action, event)
