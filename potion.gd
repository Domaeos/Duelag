extends AnimatedSprite2D

enum Potion_Type {
	HEALTH,
	MANA
}

@export var type: Potion_Type

func _ready() -> void:
	if type == Potion_Type.HEALTH:
		play("health_full")
		# handle amount here
	elif type == Potion_Type.MANA:
		play("mana_full")
	else:
		return
