extends Sprite3D

# Health bar variables
var health_bar: ProgressBar
var current_health = 100.0
var target_health = 100.0
var fill
var transition_speed = 100  # How fast the health bar transitions

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	health_bar = $SubViewport/HealthBar
	fill = health_bar.get("theme_override_styles/fill")
	print(fill)
	health_bar.value = current_health

# Smoothly update the health bar value
func _process(delta) -> void:
	# Interpolate the current health towards the target health smoothly
	current_health = lerp(current_health, target_health, transition_speed * delta)
	health_bar.value = current_health

# Function to update the target health value
func _on_update_healthbar(current_health: float, max_health: float, poisoned: bool) -> void:
	if poisoned:
		fill.bg_color = Global.poisoned_colour
	else:
		fill.bg_color = Global.health_colour

	target_health = clamp(current_health, 0.0, max_health)  # Ensure it doesn't exceed max health or go below 0
