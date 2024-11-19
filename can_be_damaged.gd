extends CharacterBody3D
class_name can_be_damaged

# Signal emitted when damage is taken
signal update_healthbar(current_health: float, max_health: float, poisoned: bool)

# Properties
@export var damageable: bool = true
@export var current_health: float = 100.0
@export var max_health: float = 100.0

var spell_emitter: AnimatedSprite2D
var spell_node: Sprite3D
var poisoned: bool = false

func _ready():
	spell_node = $SpellEmitter
	spell_emitter = $SpellEmitter/SpellNode/AnimatedSprite2D
	
func spell_landed(spell: String):
	var spell_information = Global.spelldictionary[spell]
	spell_node.position = spell_information.position
	spell_node.show()
	spell_emitter.play(spell_information.animation)
	take_damage(10)

# Take damage method
func take_damage(damage: float) -> void:
	if damageable:
		current_health -= damage
		emit_signal("update_healthbar", current_health, max_health, poisoned)

# Handle death
