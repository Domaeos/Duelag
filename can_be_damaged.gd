extends CharacterBody3D
class_name can_be_damaged

# Signal emitted when damage is taken
signal update_healthbar(current_health: float, max_health: float, poisoned: bool)

# Properties
@export var damageable: bool = true
@export var current_health: float = 100.0
@export var current_mana: float = 100.0
@export var max_health: float = 100.0
@export var poisoned: bool = false
@export var targetted: bool = false

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
	
	poison_timer.wait_time = 2.5  # Set the timer duration
	poison_timer.one_shot = false  # Set the timer to loop
	poison_timer.autostart = false  # Start the timer automatically

	# Add the timer to the current node
	add_child(poison_timer)
	poison_timer.connect("timeout", Callable(self, "_on_poisoned"))

	spell_node = $SpellEmitter
	spell_emitter = $SpellEmitter/SpellNode/AnimatedSprite2D
	print("Name: ", self.name, spell_emitter)
	
func spell_landed(spell: String):
	var spell_information = Global.spelldictionary[spell]
		
	if spell == "poison" and poisoned == false:
		poisoned = true
		poison_timer.start()
		
	if spell == "cure":
		poisoned = false
		poison_timer.stop()
		
	spell_node.position = spell_information.position
	spell_node.scale = spell_information.scale
	spell_node.show()
	spell_emitter.play(spell_information.animation)
	
	take_damage(spell_information.damage)
	
func cancel_spell():
	fizzled = true
	_on_timer_timeout()

func _on_poisoned():
	take_damage(5)
	
# Take damage method
func take_damage(damage: float) -> void:

		current_health -= damage
		emit_signal("update_healthbar", current_health, max_health, poisoned)
		if casting:
			print("spell fizzling")
			cancel_spell()

# Handle death
