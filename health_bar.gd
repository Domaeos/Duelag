extends Sprite3D

# Health bar variables
var health_bar: ProgressBar
var fill
var transition_speed = 100
var current_value

@export var healthy_fill: StyleBoxFlat
@export var poison_fill: StyleBoxFlat
@onready var bar_owner: can_be_damaged = get_parent()

func _ready() -> void:
	health_bar = $SubViewport/HealthBar
	health_bar.value = bar_owner.current_health
	health_bar.max_value = bar_owner.max_health
	current_value = bar_owner.current_health
	fill = health_bar.get("theme_override_styles/fill")
	if int(str(bar_owner.name)) == multiplayer.get_unique_id():
		set_process(false)
		hide()

func _process(delta) -> void:
	current_value = lerp(current_value, bar_owner.current_health, transition_speed * delta)
	health_bar.value = bar_owner.current_health
	if bar_owner.poisoned:
		health_bar.set("theme_override_styles/fill", poison_fill)
	else:
		health_bar.set("theme_override_styles/fill", healthy_fill)
