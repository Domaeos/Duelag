extends ColorRect

@export var player: can_be_damaged

# Health and mana variables
var target_health: float
var target_mana: float
var transition_speed: float = 5.0  # Speed of transition

var health_fill
var mana_fill

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_health = player.current_health
	target_mana = player.current_mana
	health_fill = $Player_health.get("theme_override_styles/fill")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Smoothly interpolate between the current and target health and mana
	$Player_health.value = lerp($Player_health.value, target_health, transition_speed * delta)
	$Player_mana.value = lerp($Player_mana.value, target_mana, transition_speed * delta)
	
	if player.poisoned:
		health_fill.bg_color = Global.poisoned_colour
	else:
		health_fill.bg_color = Global.health_colour
		
	# Update the target values based on player data
	target_health = player.current_health
	target_mana = player.current_mana
