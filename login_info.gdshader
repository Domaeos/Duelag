shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float glow_strength : hint_range(0.0, 2.0) = 1.0;
uniform float pulse_speed : hint_range(0.0, 5.0) = 2.0;
uniform bool is_active = false;
uniform float flash_strength : hint_range(0.0, 5.0) = 0.0; // New uniform for flash effect

void fragment() {
    vec4 base_color = texture(TEXTURE, UV);

    // Create pulsing effect
    float pulse = (sin(TIME * pulse_speed) + 1.0) * 0.5;

    // Mix with glow color
    vec4 glow = glow_color * pulse * glow_strength;

    // Add flash effect
    vec4 flash = glow_color * flash_strength;

    // Combine regular glow with flash effect
    COLOR = vec4(
        mix(base_color.rgb,
            mix(glow.rgb, flash.rgb, flash_strength),
            clamp(pulse * 0.5 + flash_strength, 0.0, 1.0)),
        base_color.a
    );
}