extends Sprite3D

# Health bar variables
var health_bar: ProgressBar
var fill
var transition_speed = 100
var current_value
var health_tween

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
	if not multiplayer.is_server():
		hide()

func _process(delta) -> void:
	if not multiplayer or not multiplayer.has_multiplayer_peer():
		return
		
	# Then check if we have our player reference
	if not Global.my_player:
		return
		
	# Now safely check the current enemy
	var my_player = Global.my_player
	var current_enemy = my_player.get("current_enemy")
		
	if str(current_enemy) == bar_owner.name:
		show()
	else:
		hide()
	
	if bar_owner.current_health != current_value:
		current_value = bar_owner.current_health
		update_health_bar(current_value)

	if bar_owner.poisoned:
		health_bar.set("theme_override_styles/fill", poison_fill)
	else:
		health_bar.set("theme_override_styles/fill", healthy_fill)

func update_health_bar(target: float) -> void:
	if health_tween:
		health_tween.kill()

	health_tween = create_tween()
	health_tween.tween_property(health_bar, "value", target, 0.5)
