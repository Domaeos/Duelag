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
		# handle amount here
	else:
		# empty
		return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# check potion level
	pass
