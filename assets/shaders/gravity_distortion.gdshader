shader_type canvas_item;

uniform float distortion_strength : hint_range(0.0, 1.0) = 0.3;
uniform float edge_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.0;
uniform vec4 color : source_color = vec4(0.0, 0.5, 1.0, 0.2);

void fragment() {
    // Calculate distance from center (0.5, 0.5)
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(UV, center) * 2.0; // Normalize to 0-1 range
    
    // Create pulsing effect
    float time_factor = sin(TIME * pulse_speed) * 0.5 + 0.5;
    
    // Edge glow effect
    float edge = smoothstep(0.8, 1.0, dist);
    edge = edge * edge_intensity * (0.8 + time_factor * 0.4);
    
    // Distortion effect (stronger near edges)
    float distortion = dist * dist * distortion_strength * (0.5 + time_factor * 0.5);
    
    // Apply color with transparency gradient from center to edge
    float alpha = smoothstep(1.0, 0.0, dist) * color.a;
    vec4 final_color = vec4(color.rgb, alpha);
    
    // Add edge glow
    final_color.rgb += vec3(edge);
    
    COLOR = final_color;
}