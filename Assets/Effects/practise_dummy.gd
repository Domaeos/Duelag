extends can_be_damaged

var health_bar: ProgressBar

func _ready() -> void:
	super._ready()
	# Reference the HealthBar node
	health_bar = $HealthBar/SubViewport/HealthBar

	# Ensure the node exists
	if health_bar == null:
		print("HealthBar node not found!")
		return

	# Set initial values
	health_bar.max_value = max_health  # Ensure the ProgressBar has a max value
	health_bar.value = current_health  # Set the current value

func _process(delta: float) -> void:
	if health_bar == null:
		print("HealthBar node not found!")
		return
		
	if targetted != true:
		health_bar.hide()
	else:
		health_bar.show()
