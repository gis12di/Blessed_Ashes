shader_type canvas_item;

uniform float border_size : hint_range(0.0, 0.5) = 0.1;
uniform vec4 color : source_color = vec4(0.0, 0.2, 0.6, 0.5); // azul semi-transparente

void fragment() {
    vec2 uv = UV;
    float fade_x = smoothstep(0.0, border_size, uv.x) * (1.0 - smoothstep(1.0 - border_size, 1.0, uv.x));
    float fade_y = smoothstep(0.0, border_size, uv.y) * (1.0 - smoothstep(1.0 - border_size, 1.0, uv.y));
    float fade = fade_x * fade_y;

    // Pintamos el color y lo multiplicamos por la transparencia del borde
    COLOR = color;
    COLOR.a *= fade;
}
