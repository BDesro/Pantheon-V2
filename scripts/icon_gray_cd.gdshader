shader_type canvas_item;

uniform float cooldown_percent : hint_range(0.0, 1.0);

void fragment() {
    vec2 uv = UV - vec2(0.5);          // center coordinates
    float angle = atan(uv.y, uv.x);     // radians (-PI..PI)

    // Rotate so 0 starts at top (12 o'clock) and increase clockwise
    float pct = mod((-angle / (2.0 * PI)) + 0.75, 1.0);

    if (pct < cooldown_percent) {
        COLOR = vec4(0.086, 0.086, 0.086, 0.8); // gray overlay
    } else {
        COLOR.a = 0.0;                    // transparent (reveals base icon)
    }
}
