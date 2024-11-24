extends ColorRect

@export var player: can_be_damaged
@export var mana_fill_style: StyleBoxFlat
@export var health_fill_style: StyleBoxFlat
@export var poison_fill_style: StyleBoxFlat

var target_health: float
var target_mana: float
var transition_speed: float = 5.0

func _ready() -> void:
	player = get_parent().get_parent()
	if player:
		print(player)
		target_health = player.current_health
		target_mana = player.current_mana
	$Player_health.set("theme_override_styles/fill", health_fill_style)
	$Player_mana.set("theme_override_styles/fill", mana_fill_style)

func _process(delta: float) -> void:
	if player:
		if player.poisoned:
			$Player_health.set("theme_override_styles/fill", poison_fill_style)
		else:
			$Player_health.set("theme_override_styles/fill", health_fill_style)
		
		target_health = player.current_health
		target_mana = player.current_mana
		
		$Player_health.value = lerp($Player_health.value, target_health, transition_speed * delta)
		$Player_mana.value = lerp($Player_mana.value, target_mana, transition_speed * delta)
