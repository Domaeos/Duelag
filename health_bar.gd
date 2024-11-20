extends Sprite3D

# Health bar variables
var health_bar: ProgressBar
var current_health = 100.0
var target_health = 100.0
var fill
var transition_speed = 100

@export var healthy_fill: StyleBoxFlat
@export var poison_fill: StyleBoxFlat

func _ready() -> void:
	health_bar = $SubViewport/HealthBar
	health_bar.value = current_health
	fill = health_bar.get("theme_override_styles/fill")

func _process(delta) -> void:
	current_health = lerp(current_health, target_health, transition_speed * delta)
	health_bar.value = current_health

func _on_update_healthbar(current_health: float, max_health: float, poisoned: bool) -> void:
	print()
	if poisoned:
		health_bar.set("theme_override_styles/fill", poison_fill)
	else:
		health_bar.set("theme_override_styles/fill", healthy_fill)

	target_health = clamp(current_health, 0.0, max_health)  # Ensure it doesn't exceed max health or go below 0
