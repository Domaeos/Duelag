extends ColorRect

@export var player: can_be_damaged
@export var mana_fill_style: StyleBoxFlat
@export var health_fill_style: StyleBoxFlat
@export var poison_fill_style: StyleBoxFlat

var target_health: float
var target_mana: float
var transition_speed: float = 5.0

var debug_timer

var health_potion_sprite: AnimatedSprite2D
var mana_potion_sprite: AnimatedSprite2D

func _ready() -> void:
	var control = get_parent()
	player = control.get_parent()
	
	if not player or int(str(player.name)) != multiplayer.get_unique_id(): 
		set_process(false)
		hide()
		return
	
	health_potion_sprite = control.get_node("HealthPotion")
	mana_potion_sprite = control.get_node("ManaPotion")
	target_health = player.current_health
	target_mana = player.current_mana
	debug_timer = Timer.new()
	debug_timer.autostart = true
	debug_timer.wait_time = 3
	debug_timer.one_shot = false
	debug_timer.connect("timeout", _on_debug_timeout)
	add_child(debug_timer)
	$Player_health.set("theme_override_styles/fill", health_fill_style)
	$Player_mana.set("theme_override_styles/fill", mana_fill_style)

func _on_debug_timeout():
	print("Debugging: ", player.name)
	print("Player mana: ", player.current_mana)
	
func _process(delta: float) -> void:
	if player:
		if player.potion_timer:
			var potion_progress = player.potion_timer.time_left / player.potion_timer.wait_time
			update_sprite_transparency(health_potion_sprite, potion_progress)
			update_sprite_transparency(mana_potion_sprite, potion_progress)
			
		if player.poisoned:
			$Player_health.set("theme_override_styles/fill", poison_fill_style)
		else:
			$Player_health.set("theme_override_styles/fill", health_fill_style)
		
		target_health = player.current_health
		target_mana = player.current_mana
		
		$Player_health.value = lerp($Player_health.value, target_health, transition_speed * delta)
		$Player_mana.value = lerp($Player_mana.value, target_mana, transition_speed * delta)

func update_sprite_transparency(sprite: AnimatedSprite2D, progress: float) -> void:
	var alpha = lerp(1.0, 0.05, progress)
	var modulate = sprite.modulate
	modulate.a = alpha
	sprite.modulate = modulate
