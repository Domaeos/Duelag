shader_type canvas_item;

// Define uniforms for the clipping rectangle
uniform float clip_x : hint_range(-1024, 1024); // X position of the smaller rectangle
uniform float clip_y : hint_range(-1024, 1024); // Y position of the smaller rectangle
uniform float clip_width : hint_range(0, 1024); // Width of the smaller rectangle
uniform float clip_height : hint_range(0, 1024); // Height of the smaller rectangle

void fragment() {
    vec2 pos = FRAGCOORD.xy;
    
    // Check if the fragment is within the clipping rectangle
    if (pos.x >= clip_x && pos.x <= clip_x + clip_width &&
        pos.y >= clip_y && pos.y <= clip_y + clip_height) {
        discard; // Discard pixels inside the clipping rectangle
    }
    
    // Otherwise, display the original texture
    COLOR = texture(TEXTURE, UV);
}
