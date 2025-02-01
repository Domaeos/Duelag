shader_type canvas_item;

// 9348EE = rgb(147, 72, 238) = vec4(0.576, 0.282, 0.933, 1.0)
// 72366A = rgb(114, 54, 106) = vec4(0.447, 0.212, 0.416, 1.0)
// 7E1897 = rgb(126, 24, 151) = vec4(0.494, 0.094, 0.592, 1.0)
// DA36FB = rgb(218, 54, 251) = vec4(0.855, 0.212, 0.984, 1.0)

uniform vec4 color_1 : source_color = vec4(0.576, 0.282, 0.933, 1.0);  // 9348EE
uniform vec4 color_2 : source_color = vec4(0.447, 0.212, 0.416, 1.0);  // 72366A
uniform vec4 color_3 : source_color = vec4(0.494, 0.094, 0.592, 1.0);  // 7E1897
uniform vec4 color_4 : source_color = vec4(0.855, 0.212, 0.984, 1.0);  // DA36FB
uniform float border_width : hint_range(0, 20) = 4.0;
uniform float speed : hint_range(0, 5) = 0.2;
uniform float gradient_length : hint_range(0, 2) = 1.5;

void fragment() {
    vec4 color = texture(TEXTURE, UV);

    vec2 dist_from_edge;
    dist_from_edge.x = min(UV.x, 1.0 - UV.x);
    dist_from_edge.y = min(UV.y, 1.0 - UV.y);
    float edge_dist = min(dist_from_edge.x, dist_from_edge.y);

    float border_mask = step(edge_dist, border_width * TEXTURE_PIXEL_SIZE.x);

    float gradient_pos = UV.y - TIME * speed;
    gradient_pos = fract(gradient_pos) * 3.0;  // Multiply by 3 to split into thirds

    vec4 border_color;
    if (gradient_pos < 1.0) {
        border_color = mix(color_1, color_2, smoothstep(0.0, 1.0, gradient_pos));
    } else if (gradient_pos < 2.0) {
        border_color = mix(color_2, color_3, smoothstep(1.0, 2.0, gradient_pos));
    } else {
        border_color = mix(color_3, color_4, smoothstep(2.0, 3.0, gradient_pos));
    }

    COLOR = mix(color, border_color, border_mask * border_color.a);
}