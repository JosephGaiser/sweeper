shader_type canvas_item;

uniform float distortion_amount : hint_range(0.0, 0.1) = 0.02;
uniform float wave_speed : hint_range(0.0, 5.0) = 2.0;
uniform float wave_frequency : hint_range(0.0, 50.0) = 20.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // Calculate distance from center (0.5, 0.5)
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(UV, center) * 2.0; // Normalize to 0-1 range
    
    // Create wave effect that moves outward from center
    float wave = sin(dist * wave_frequency - TIME * wave_speed);
    
    // Stronger distortion near the center, fading to edges
    float distortion_factor = (1.0 - dist) * distortion_amount * wave;
    
    // Calculate direction from center to current pixel
    vec2 direction = normalize(UV - center);
    
    // Apply distortion to screen texture coordinates
    vec2 distorted_uv = SCREEN_UV + direction * distortion_factor;
    
    // Sample the screen texture with distorted coordinates
    vec4 screen_color = texture(SCREEN_TEXTURE, distorted_uv);
    
    // Fade out the effect at the edges
    float edge_fade = smoothstep(1.0, 0.8, dist);
    
    // Mix between original and distorted based on distance
    COLOR = screen_color * edge_fade;
}