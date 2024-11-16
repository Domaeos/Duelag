extends CharacterBody3D
class_name can_be_damaged

# Signal emitted when damage is taken
signal damage_taken(damage: float)

# Properties
@export var damageable: bool = true
@export var current_health: float = 100.0
@export var max_health: float = 100.0
var poisoned: bool = false

# Take damage method
func take_damage(damage: float) -> void:
	if damageable:
		current_health -= damage
		emit_signal("damage_taken", damage)

# Handle death
