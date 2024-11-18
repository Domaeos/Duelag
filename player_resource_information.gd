extends ColorRect

@export var player: can_be_damaged
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Player_health.value = player.current_health
	$Player_mana.value = player.current_mana
