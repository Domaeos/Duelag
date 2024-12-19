extends ColorRect

var player
@export var mana_fill_style: StyleBoxFlat
@export var health_fill_style: StyleBoxFlat
@export var poison_fill_style: StyleBoxFlat

var health_tween
var mana_tween
var potion_tween

var target_health: float
var target_mana: float
var transition_speed: float = 5.0

var debug_timer

var health_potion_sprite: AnimatedSprite2D
var mana_potion_sprite: AnimatedSprite2D

func _ready() -> void:
	var control = get_parent()
	player = control.get_parent()
	health_potion_sprite = control.get_node_or_null("HealthPotion")
	mana_potion_sprite = control.get_node_or_null("ManaPotion")
	target_health = player.current_health
	target_mana = player.current_mana
	#debug_timer = Timer.new()
	#debug_timer.autostart = true
	#debug_timer.wait_time = 3
	#debug_timer.one_shot = false
	#debug_timer.connect("timeout", _on_debug_timeout)
	var is_player = int(str(player.name)) == multiplayer.get_unique_id()
	set_process(is_player)
	set_multiplayer_authority(is_player)
	
	if not health_potion_sprite:
		print("ERROR: Health Potion Sprite not found!")
	if not mana_potion_sprite:
		print("ERROR: Mana Potion Sprite not found!")

	$Player_health.set("theme_override_styles/fill", health_fill_style)
	$Player_mana.set("theme_override_styles/fill", mana_fill_style)

func _on_debug_timeout():
	pass
	#print("Player health: ", player.current_health, " for: ", multiplayer.get_unique_id())
	
func _process(delta: float) -> void:
	if player:
		if player.potion_cooldown:
			health_potion_sprite.modulate.a = 0.25;
			mana_potion_sprite.modulate.a = 0.25;
		else:
			health_potion_sprite.modulate.a = 1;
			mana_potion_sprite.modulate.a = 1;
			
		if player.poisoned:
			$Player_health.set("theme_override_styles/fill", poison_fill_style)
		else:
			$Player_health.set("theme_override_styles/fill", health_fill_style)
		
	#	Update health
		if target_health != player.current_health:
			target_health = player.current_health
			update_health_bar(target_health)
		
		# Update mana
		if target_mana != player.current_mana:
			target_mana = player.current_mana
			update_mana_bar(target_mana)
			
func update_health_bar(target: float) -> void:
	if health_tween:
		health_tween.kill()
	
	health_tween = create_tween()
	health_tween.tween_property($Player_health, "value", target, 0.5)

func update_mana_bar(target: float) -> void:
	if mana_tween:
		mana_tween.kill()
	
	mana_tween = create_tween()
	mana_tween.tween_property($Player_mana, "value", target, 0.5)

	
func initiate_potion_tween(time):
	health_potion_sprite.modulate.a = 0
	mana_potion_sprite.modulate.a = 0
	potion_tween = create_tween()
	potion_tween.set_parallel()
	potion_tween.tween_property(health_potion_sprite, "modulate:a", 1, time)
	potion_tween.tween_property(mana_potion_sprite, "modulate:a", 1, time)
	
