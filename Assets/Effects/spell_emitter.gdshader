shader_type canvas_item;

uniform float hue_shift : hint_range(-1.0, 1.0);

vec3 rgb2hsv(vec3 c) {
    float c_max = max(c.r, max(c.g, c.b));
    float c_min = min(c.r, min(c.g, c.b));
    float delta = c_max - c_min;

    float h = 0.0;
    if (delta > 0.0) {
        if (c_max == c.r) {
            h = mod((c.g - c.b) / delta, 6.0);
        } else if (c_max == c.g) {
            h = (c.b - c.r) / delta + 2.0;
        } else if (c_max == c.b) {
            h = (c.r - c.g) / delta + 4.0;
        }
        h /= 6.0;
    }

    float s = c_max == 0.0 ? 0.0 : delta / c_max;
    float v = c_max;

    return vec3(h, s, v);
}

vec3 hsv2rgb(vec3 c) {
    float h = c.x * 6.0;
    float s = c.y;
    float v = c.z;

    float c_value = v * s;
    float x = c_value * (1.0 - abs(mod(h, 2.0) - 1.0));
    float m = v - c_value;

    vec3 rgb;
    if (h < 1.0) {
        rgb = vec3(c_value, x, 0.0);
    } else if (h < 2.0) {
        rgb = vec3(x, c_value, 0.0);
    } else if (h < 3.0) {
        rgb = vec3(0.0, c_value, x);
    } else if (h < 4.0) {
        rgb = vec3(0.0, x, c_value);
    } else if (h < 5.0) {
        rgb = vec3(x, 0.0, c_value);
    } else {
        rgb = vec3(c_value, 0.0, x);
    }

    return rgb + vec3(m);
}

void fragment() {
    vec3 tex_color = texture(TEXTURE, UV).rgb;
    vec3 color_hsv = rgb2hsv(tex_color);
    color_hsv.x += hue_shift; // Shift hue
    color_hsv.x = mod(color_hsv.x, 1.0); // Wrap hue between 0 and 1
    COLOR.rgb = hsv2rgb(color_hsv);
    COLOR.a = texture(TEXTURE, UV).a; // Preserve original alpha
}
