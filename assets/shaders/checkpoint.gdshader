shader_type canvas_item;

uniform float speed : hint_range(0.1, 5.0) = 2.0;
uniform float light_width : hint_range(0.1, 1.0) = 0.3;
uniform float light_intensity : hint_range(0.0, 3.0) = 2.0;
uniform vec4 light_color : source_color = vec4(1.0, 1.0, 0.5, 1.0);
uniform float fade_distance : hint_range(0.0, 0.5) = 0.2;

vec2 get_edge_position(float t) {
    // Normalize t to 0-1 range
    t = fract(t);

    vec2 pos;
    if (t < 0.25) {
        // Top edge: left to right
        float progress = t * 4.0;
        pos = vec2(progress, 0.0);
    } else if (t < 0.5) {
        // Right edge: top to bottom
        float progress = (t - 0.25) * 4.0;
        pos = vec2(1.0, progress);
    } else if (t < 0.75) {
        // Bottom edge: right to left
        float progress = (t - 0.5) * 4.0;
        pos = vec2(1.0 - progress, 1.0);
    } else {
        // Left edge: bottom to top
        float progress = (t - 0.75) * 4.0;
        pos = vec2(0.0, 1.0 - progress);
    }

    return pos;
}

float get_distance_to_edge(vec2 uv) {
    // Calculate distance to nearest edge
    float dist_to_left = uv.x;
    float dist_to_right = 1.0 - uv.x;
    float dist_to_top = uv.y;
    float dist_to_bottom = 1.0 - uv.y;

    return min(min(dist_to_left, dist_to_right), min(dist_to_top, dist_to_bottom));
}

void fragment() {
    vec2 uv = UV;
    vec4 tex_color = texture(TEXTURE, uv);

    // Only apply effect where the original texture has alpha > 0 (the outline)
    if (tex_color.a < 0.1) {
        COLOR = tex_color;
		// return
    }

    // Calculate current light position based on time
    float current_time = TIME * speed;
    vec2 light_pos = get_edge_position(current_time);

    // Calculate distance from current pixel to light position
    float dist_to_light = distance(uv, light_pos);

    // Only apply light effect near edges
    float edge_distance = get_distance_to_edge(uv);
    float edge_mask = 1.0 - smoothstep(0.0, fade_distance, edge_distance);

    // Create light falloff
    float light_falloff = 1.0 - smoothstep(0.0, light_width, dist_to_light);
    light_falloff = pow(light_falloff, 2.0); // Make falloff sharper

    // Combine light with original color
    vec3 final_color = tex_color.rgb + (light_color.rgb * light_falloff * light_intensity * edge_mask);

    COLOR = vec4(final_color, tex_color.a);
}