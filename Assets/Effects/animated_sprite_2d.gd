extends AnimatedSprite2D

func _ready():
	# Set initial hue shift (just an example)
	material.set("shader_param/hue_shift", 0.5)

func _process(delta):
	# Animate the hue shift using time in seconds
	var hue = sin(Time.get_time()) * 0.5  # Get the time in seconds
	material.set("shader_param/hue_shift", hue)
