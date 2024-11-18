extends Sprite3D

# Health bar variables
onready var health_bar = $SubViewport/HealthBar
var current_health = 100.0
var target_health = 100.0
var transition_speed = 5.0  # How fast the health bar transitions

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	health_bar.value = current_health

# Smoothly update the health bar value
func _process(delta) -> void:
	# Interpolate the current health towards the target health smoothly
	current_health = lerp(current_health, target_health, transition_speed * delta)
	
	# Update the health bar's value with the current health
	health_bar.value = current_health

# Function to update the target health value
func _on_update_healthbar(current_health: float, max_health: float, poisoned: bool) -> void:
	target_health = clamp(current_health, 0.0, max_health)  # Ensure it doesn't exceed max health or go below 0
