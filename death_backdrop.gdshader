shader_type canvas_item;

uniform float grayscale_intensity: hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 original_color = texture(TEXTURE, UV);
    float gray = dot(original_color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 grayscale_color = vec3(gray);
    COLOR.rgb = mix(original_color.rgb, grayscale_color, grayscale_intensity);
}