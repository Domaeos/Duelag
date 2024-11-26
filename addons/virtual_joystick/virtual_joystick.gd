class_name VirtualJoystick

extends Control

## A simple virtual joystick for touchscreens, with useful options.
## Github: https://github.com/MarcoFazioRandom/Virtual-Joystick-Godot

# EXPORTED VARIABLE

## The color of the button when the joystick is pressed.
@export var pressed_color := Color.GRAY

## If the input is inside this range, the output is zero.
@export_range(0, 200, 1) var deadzone_size : float = 10

## The max distance the tip can reach.
@export_range(0, 500, 1) var clampzone_size : float = 75

enum Joystick_mode {
	FIXED, ## The joystick doesn't move.
	DYNAMIC, ## Every time the joystick area is pressed, the joystick position is set on the touched position.
	FOLLOWING ## When the finger moves outside the joystick area, the joystick will follow it.
}

## If the joystick stays in the same position or appears on the touched position when touch is started
@export var joystick_mode := Joystick_mode.FIXED

enum Visibility_mode {
	ALWAYS, ## Always visible
	TOUCHSCREEN_ONLY, ## Visible on touch screens only
	WHEN_TOUCHED ## Visible only when touched
}

var actions = {
	"up": false,
	"down": false,
	"left": false,
	"right": false,
}

## If the joystick is always visible, or is shown only if there is a touchscreen
@export var visibility_mode := Visibility_mode.ALWAYS

## If true, the joystick uses Input Actions (Project -> Project Settings -> Input Map)
@export var use_input_actions := true

@export var action_left := "move_left"
@export var action_right := "move_right"
@export var action_up := "move_up"
@export var action_down := "move_down"

# PUBLIC VARIABLES

## If the joystick is receiving inputs.
var is_pressed := false

# The joystick output.
var output := Vector2.ZERO

# PRIVATE VARIABLES

var _touch_index : int = -1

@onready var _base := $Base
@onready var _tip := $Base/Tip

@onready var _base_default_position : Vector2 = _base.position
@onready var _tip_default_position : Vector2 = _tip.position

@onready var _default_color : Color = _tip.modulate

# FUNCTIONS

func _ready() -> void:
	#if not DisplayServer.is_touchscreen_available():
		# Disable the node (e.g., make it invisible and non-interactive)
		#visible = false
		#set_process(false)
	
	if not DisplayServer.is_touchscreen_available() and visibility_mode == Visibility_mode.TOUCHSCREEN_ONLY :
		hide()
	
	if visibility_mode == Visibility_mode.WHEN_TOUCHED:
		hide()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _is_point_inside_joystick_area(event.position) and _touch_index == -1:
				if joystick_mode == Joystick_mode.DYNAMIC or joystick_mode == Joystick_mode.FOLLOWING or (joystick_mode == Joystick_mode.FIXED and _is_point_inside_base(event.position)):
					if joystick_mode == Joystick_mode.DYNAMIC or joystick_mode == Joystick_mode.FOLLOWING:
						_move_base(event.position)
					if visibility_mode == Visibility_mode.WHEN_TOUCHED:
						show()
					_touch_index = event.index
					_tip.modulate = pressed_color
					_update_joystick(event.position)
					get_viewport().set_input_as_handled()
		elif event.canceled:
			_reset()
			if visibility_mode == Visibility_mode.WHEN_TOUCHED:
				hide()
	elif event is InputEventScreenDrag:
		if event.index == _touch_index:
			_update_joystick(event.position)

func _move_base(new_position: Vector2) -> void:
	_base.global_position = new_position - _base.pivot_offset * get_global_transform_with_canvas().get_scale()

func _move_tip(new_position: Vector2) -> void:
	_tip.global_position = new_position - _tip.pivot_offset * _base.get_global_transform_with_canvas().get_scale()

func _is_point_inside_joystick_area(point: Vector2) -> bool:
	var x: bool = point.x >= global_position.x and point.x <= global_position.x + (size.x * get_global_transform_with_canvas().get_scale().x)
	var y: bool = point.y >= global_position.y and point.y <= global_position.y + (size.y * get_global_transform_with_canvas().get_scale().y)
	return x and y

func _get_base_radius() -> Vector2:
	return _base.size * _base.get_global_transform_with_canvas().get_scale() / 2

func _is_point_inside_base(point: Vector2) -> bool:
	var _base_radius = _get_base_radius()
	var center : Vector2 = _base.global_position + _base_radius
	var vector : Vector2 = point - center
	if vector.length_squared() <= _base_radius.x * _base_radius.x:
		return true
	else:
		return false

func _update_joystick(touch_position: Vector2) -> void:
	var _base_radius = _get_base_radius()
	var center : Vector2 = _base.global_position + _base_radius
	var vector : Vector2 = touch_position - center
	vector = vector.limit_length(clampzone_size)
	
	if joystick_mode == Joystick_mode.FOLLOWING and touch_position.distance_to(center) > clampzone_size:
		_move_base(touch_position - vector)
	
	_move_tip(center + vector)
	
	if vector.length_squared() > deadzone_size * deadzone_size:
		is_pressed = true
		output = (vector - (vector.normalized() * deadzone_size)) / (clampzone_size - deadzone_size)
		_handle_8way_input(output)
	else:
		is_pressed = false
		_reset()
		output = Vector2.ZERO
		_reset_input_actions()  # Clear all pressed directions when the joystick is in the deadzone

func _reset():
	is_pressed = false
	output = Vector2.ZERO
	_touch_index = -1
	_tip.modulate = _default_color
	_base.position = _base_default_position
	_tip.position = _tip_default_position
	_reset_input_actions()  # Clear all pressed directions
	
func _handle_8way_input(direction: Vector2) -> void:
	# Calculate the angle in degrees
	var angle = rad_to_deg(direction.angle())
	# Wrap the angle to be within 0-360
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
	actions.up = press_up
	actions.down = press_down
	actions.left = press_left
	actions.right = press_right

func _reset_input_actions() -> void:
	# Release all directional input actions
	for direction in actions:
		direction = false
