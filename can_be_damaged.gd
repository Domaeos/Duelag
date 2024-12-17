extends CharacterBody3D
class_name can_be_damaged

# Properties
@export var damageable: bool = true
@export var current_health: float = 100.0:
	set(value):
		current_health = clamp(value, 0, max_health)

@export var current_mana: float = 100.0
@export var max_mana: float = 100.0
@export var max_health: float = 100.0
@export var poisoned: bool = false

var casting: bool = false
var current_spell: String
var poison_timer
var spell_emitter: AnimatedSprite2D
var spell_node: Sprite3D
var spell_timer: Timer
var fizzled: bool

func _on_timer_timeout() -> void:
	pass

func _ready():
	poison_timer = Timer.new()
	spell_timer = Timer.new()
	spell_timer.one_shot = true
	spell_timer.autostart = false
	add_child(spell_timer)
	spell_timer.connect("timeout", Callable(self, "_on_spell_timeout"))

	poison_timer.wait_time = 2.5
	poison_timer.one_shot = false
	poison_timer.autostart = false
	add_child(poison_timer)
	poison_timer.connect("timeout", Callable(self, "_on_poisoned"))

	spell_node = $SpellEmitter
	spell_emitter = $SpellEmitter/SpellNode/AnimatedSprite2D

@rpc("any_peer", "call_local")
func spell_landed(spell: String):
	if multiplayer.get_remote_sender_id() == 1:
		var landed_on_id = multiplayer.get_unique_id()
		var spell_information = Global.spelldictionary[spell]
		if spell == "poison" and poisoned == false:
			poisoned = true
			poison_timer.start()

		if spell == "cure":
			poisoned = false
			poison_timer.stop()

		rpc("show_effect", landed_on_id, spell)
		take_damage(spell_information.damage)

@rpc("any_peer", "call_local", "reliable", 2)
func show_effect(id, spell: String):
	var node = get_parent().get_node(str(id))
	var spell_information = Global.spelldictionary[spell]

	node.spell_node.position = spell_information.position
	node.spell_node.scale = spell_information.scale
	node.spell_node.show()
	node.spell_emitter.play(spell_information.animation)

func cancel_spell():
	fizzled = true
	_on_timer_timeout()

func _on_poisoned():
	take_damage(2.0)

@rpc("authority", "call_local", "reliable")
func take_damage(damage: float) -> void:
	if multiplayer.is_server() or is_multiplayer_authority():
		current_health -= damage
		print("Health after damage: ", current_health)

		if current_health <= 0:
			# Handle player death if needed
			pass
