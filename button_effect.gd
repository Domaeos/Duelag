extends TextureButton

func _ready():
	# Create shader material
	var shader_material = ShaderMaterial.new()
	shader_material.shader = preload("res://button_effect.gdshader")  # Save shader as button_shader.gdshader
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	# Set initial uniform values
	shader_material.set_shader_parameter("glow_color", Color(1, 1, 1, 0.3))
	shader_material.set_shader_parameter("scroll_speed", 0.5)
	shader_material.set_shader_parameter("shine_opacity", 0.3)
	shader_material.set_shader_parameter("shine_width", 0.2)
	shader_material.set_shader_parameter("hover_glow_strength", 0.3)
	shader_material.set_shader_parameter("click_distortion", 0.02)
	
	# Apply shader material
	material = shader_material

# Mouse enter/exit for hover effect
func _on_mouse_entered():
	material.set_shader_parameter("is_hovered", true)

func _on_mouse_exited():
	material.set_shader_parameter("is_hovered", false)

# Button press/release for click effect
func _on_button_down():
	material.set_shader_parameter("is_pressed", true)

func _on_button_up():
	material.set_shader_parameter("is_pressed", false)
