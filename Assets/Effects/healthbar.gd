extends ProgressBar

signal on_health_change(currentHealth: float, maxHealth: float, poisoned: bool)
@export var character: can_be_damaged

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
