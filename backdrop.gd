extends ColorRect

func _ready():
	# Make it cover the whole viewport
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Create and set up the shader material
	var shader_material = ShaderMaterial.new()
	var shader = Shader.new()
	shader.code = """
	shader_type canvas_item;
	
	uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
	uniform float grayscale_intensity: hint_range(0.0, 1.0) = 0.0;
	
	void fragment() {
		vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
		float gray = dot(screen_color.rgb, vec3(0.299, 0.587, 0.114));
		vec3 grayscale_color = vec3(gray);
		COLOR.rgb = mix(screen_color.rgb, grayscale_color, grayscale_intensity);
		COLOR.a = 1.0;
	}
	"""
	shader_material.shader = shader
	material = shader_material
	material.set_shader_parameter("grayscale_intensity", 0.0)

func start_death_overlay():
	var tween = create_tween()
	tween.tween_property(material, "shader_parameter/grayscale_intensity", 1.0, 0.5)
