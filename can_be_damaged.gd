extends CharacterBody3D
class_name can_be_damaged

# Signal emitted when damage is taken
signal update_healthbar(current_health: float, max_health: float, poisoned: bool)

# Properties
@export var damageable: bool = true
@export var current_health: float = 100.0
@export var max_health: float = 100.0
var poisoned: bool = false

func spell_landed(spell: String):
	print("IVE BEEN HIT")
	$Firestrike.show()
	$Firestrike/Fire_1/AnimatedSprite2D.play("explode")
	take_damage(35)

# Take damage method
func take_damage(damage: float) -> void:
	if damageable:
		current_health -= damage
		emit_signal("update_healthbar", current_health, max_health, poisoned)

# Handle death
