extends can_be_damaged

func _ready() -> void:
	# Reference the HealthBar node
	var health_bar: ProgressBar = $HealthBar

	# Ensure the node exists
	if health_bar == null:
		print("HealthBar node not found!")
		return

	# Set initial values
	health_bar.max_value = max_health  # Ensure the ProgressBar has a max value
	health_bar.value = current_health  # Set the current value
