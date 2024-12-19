shader_type spatial;

uniform vec4 outline_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float outline_width : hint_range(0.0, 1.0) = 0.1;

void vertex() {
    // Scale the vertex along its normal for the outline effect
    VERTEX += NORMAL * outline_width;
}

void fragment() {
    // Set the outline color
    ALBEDO = outline_color.rgb;
}	