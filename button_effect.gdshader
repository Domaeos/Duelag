shader_type canvas_item;

uniform vec4 shine_color : source_color = vec4(1.0, 1.0, 1.0, 0.15);  // Reduced opacity
uniform float rotation_speed : hint_range(0, 1) = 0.2;  // Slowed down
uniform float light_size : hint_range(0, 1) = 0.8;  // Size of the light area
uniform float shine_strength : hint_range(0, 1) = 0.15;  // Reduced strength
uniform float hover_glow_strength : hint_range(0, 1) = 0.15;
uniform float click_darken : hint_range(0, 1) = 0.2;  // How much to darken on click

uniform bool is_hovered = false;
uniform bool is_pressed = false;

void fragment() {
    // Get base texture color
    vec2 uv = UV * 2.0 - 1.0;  // Center coordinates (-1 to 1)

    // Calculate rotating light position
    float angle = TIME * rotation_speed;
    vec2 light_pos = vec2(
        cos(angle) * 0.6,  // Radius of rotation
        sin(angle) * 0.6
    );

    // Calculate distance from light to current pixel
    float dist = length(uv - light_pos);
    float light = smoothstep(light_size, 0.0, dist);

    // Get texture color
    vec4 color = texture(TEXTURE, UV);

    // Add subtle rotating light
    color.rgb += light * shine_strength * shine_color.rgb;

    // Add hover effect (subtle glow)
    if (is_hovered) {
        float pulse = (sin(TIME * 2.0) + 1.0) * 0.5 * hover_glow_strength;
        color.rgb += pulse * shine_color.rgb;
    }

    // Darken when clicked
    if (is_pressed) {
        color.rgb *= (1.0 - click_darken);
    }

    COLOR = color;
}