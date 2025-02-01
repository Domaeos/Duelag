# loginpanel.gd
extends PanelContainer

# UI States
enum UIState { LOGIN, REGISTER, SAVED_LOGIN }

# Constants
const ANIMATION_DURATION = 0.3
const RESET_TIMER_DURATION = 4.0

# Node References - Keep these as direct references to avoid null issues
@onready var register_fields = $MarginContainer/VBoxContainer/RegisterFields
@onready var nav_button = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/RegisterButton
@onready var nav_label = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/RegisterButton/Label
@onready var action_button = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/LoginButton
@onready var action_label = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/LoginButton/Label
@onready var info_label = $MarginContainer/VBoxContainer/InfoContainer/VBoxContainer/InfoLabel
@onready var message_label = $MarginContainer/VBoxContainer/InfoContainer/VBoxContainer/MessageLabel
@onready var email_field = $MarginContainer/VBoxContainer/Email
@onready var password_field = $MarginContainer/VBoxContainer/Password
@onready var saved_account_panel = $MarginContainer/VBoxContainer/AccountSavedPanel
@onready var remember_button = $MarginContainer/VBoxContainer/MarginContainer2/CenterContainer/CheckBox
@onready var error_label = $MarginContainer/VBoxContainer/ErrorLabel

# State Management
var current_state: UIState = UIState.LOGIN
var fields_disabled: bool = false
var timer: Timer
var Auth: Node

class UIStateManager:
	var panel: Node
	
	func _init(panel_instance: Node):
		panel = panel_instance
	
	func update_state(new_state: UIState) -> void:
		match new_state:
			UIState.LOGIN:
				panel._set_login_state()
			UIState.REGISTER:
				panel._set_register_state()
			UIState.SAVED_LOGIN:
				panel._set_saved_login_state()

func _ready() -> void:
	_setup_timer()
	_initialize_auth()
	_setup_ui()
	_check_saved_account()

# Initialization Methods
func _setup_timer() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = RESET_TIMER_DURATION
	timer.one_shot = true
	timer.timeout.connect(reset_view)

func _initialize_auth() -> void:
	Auth = get_tree().current_scene.get_node("Auth")

func _setup_ui() -> void:
	register_fields.hide()
	nav_button.pressed.connect(_on_navigation_pressed)
	action_button.pressed.connect(_on_action_button_pressed)

func _check_saved_account() -> void:
	if has_saved_account_data():
		var data = get_account_data()
		if data:
			_load_saved_account(data)

# UI State Management
func _set_login_state() -> void:
	register_fields.hide()
	action_label.text = "Login"
	nav_label.text = "Register"
	nav_button.button_pressed = false
	email_field.show()
	password_field.show()
	saved_account_panel.hide()

func _set_register_state() -> void:
	_animate_register_fields(true)
	nav_label.text = "Cancel"
	action_label.text = "Create"

func _set_saved_login_state() -> void:
	email_field.hide()
	password_field.hide()
	saved_account_panel.show()
	saved_account_panel.populate_fields()
	remember_button.button_pressed = true
	action_label.text = "Enter"
	nav_label.text = "Logout"
	nav_button.button_pressed = true

# Animation
func _animate_register_fields(show: bool) -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT if show else Tween.EASE_IN)\
							 .set_trans(Tween.TRANS_CUBIC)
	
	if show:
		register_fields.custom_minimum_size.y = 0
		register_fields.show()
		register_fields.modulate.a = 0
		register_fields.pivot_offset = Vector2.ZERO
		
		var target_size = register_fields.size.y
		tween.parallel().tween_property(register_fields, "modulate:a", 1.0, ANIMATION_DURATION)
		tween.parallel().tween_property(register_fields, "custom_minimum_size:y", target_size, ANIMATION_DURATION)
	else:
		tween.parallel().tween_property(register_fields, "modulate:a", 0.0, ANIMATION_DURATION)
		tween.parallel().tween_property(register_fields, "custom_minimum_size:y", 0, ANIMATION_DURATION)
		tween.tween_callback(func(): register_fields.hide())

# Account Management
func _load_saved_account(data: Dictionary) -> void:
	Global.account = data
	current_state = UIState.SAVED_LOGIN
	UIStateManager.new(self).update_state(current_state)

# Event Handlers
func _on_navigation_pressed() -> void:
	if nav_label.text == "Logout":
		_handle_logout()
		return
		
	current_state = UIState.LOGIN if current_state == UIState.REGISTER else UIState.REGISTER
	UIStateManager.new(self).update_state(current_state)

func _on_action_button_pressed() -> void:
	toggle_form()
	var action = action_label.text
	_handle_action(action)

# Helper Methods
func _handle_logout() -> void:
	current_state = UIState.LOGIN
	delete_account_data()
	UIStateManager.new(self).update_state(current_state)

func _handle_action(action: String) -> void:
	match action:
		"Create":
			Auth.action_request("Register")
			_update_info_label("Creating account..")
		"Login":
			Auth.action_request("Login")
			_update_info_label("Logging you in..")
		"Enter":
			Auth.action_request("Verify")
			_update_info_label("Logging you in..")

func _update_info_label(text: String) -> void:
	info_label.text = "[center]" + text + "[/center]"
	info_label.start_glowing()

func _update_error_label(text: String) -> void:
	error_label.visible = true
	error_label.text = text
	toggle_form()


# Form Management
func toggle_form(empty_form: bool = false) -> void:
	var line_edits = find_children("*", "LineEdit")
	for line in line_edits:
		line.editable = fields_disabled
		if empty_form:
			line.text = ""
			
	action_button.disabled = !fields_disabled
	nav_button.disabled = !fields_disabled
	fields_disabled = !fields_disabled

func reset_view(empty_form: bool = false) -> void:
	current_state = UIState.LOGIN
	UIStateManager.new(self).update_state(current_state)
	toggle_form(empty_form)
	_update_info_label("Enter the duelag")
	message_label.hide()
	message_label.text = ""
	info_label.stop_glowing()

# File Operations
func has_saved_account_data() -> bool:
	return FileAccess.file_exists(Global.SAVE_PATH)

func get_account_data() -> Dictionary:
	if not FileAccess.file_exists(Global.SAVE_PATH):
		return {}
		
	var file = FileAccess.open(Global.SAVE_PATH, FileAccess.READ)
	if not file:
		return {}
		
	var content = file.get_line()
	file.close()
	
	var json = JSON.new()
	return json.get_data() if json.parse(content) == OK else {}

func delete_account_data() -> void:
	if FileAccess.file_exists(Global.SAVE_PATH):
		DirAccess.remove_absolute(Global.SAVE_PATH)

# Error Handling
func handle_error(error: Dictionary) -> void:
	print(error.detail)
	if error.detail == "Invalid or expired refresh token":
		_update_info_label("Session expired")
		delete_account_data()
		timer.start()
	if error.detail == "Email or password is incorrect":
		_update_info_label("Oops!")
		_update_error_label(error.detail)
	
