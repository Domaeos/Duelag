extends CanvasLayer

@onready var backdrop = $Backdrop
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_menu():
	show()
	backdrop.start_death_overlay()
	pass
