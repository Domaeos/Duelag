extends RichTextLabel
var flash_tween: Tween

func _ready():
	var shader_material = ShaderMaterial.new()
	shader_material.shader = preload("res://login_info.gdshader")
	material = shader_material
	
	material.set_shader_parameter("glow_color1", Color(1.0, 0.5, 1.0, 1.0))  # Purple-ish
	material.set_shader_parameter("glow_color2", Color(0.5, 0.8, 1.0, 1.0))  # Blue-ish


func trigger_flash():
	if flash_tween:
		flash_tween.kill()
	
	material.set_shader_parameter("flash_strength", 0.0)
	
	flash_tween = create_tween()
	flash_tween.set_trans(Tween.TRANS_EXPO)
	flash_tween.set_ease(Tween.EASE_OUT)
	
	flash_tween.tween_property(material, "shader_parameter/flash_strength", 5.0, 0.1)
	flash_tween.tween_property(material, "shader_parameter/flash_strength", 0.0, 0.5)


func start_glowing():
	if material:
		material.set_shader_parameter("is_active", true)

func stop_glowing():
	if material:
		material.set_shader_parameter("is_active", false)
