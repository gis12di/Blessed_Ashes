shader_type canvas_item;

// Colores para el degradado horizontal
uniform vec4 color_left : source_color = vec4(0.3, 0.6, 1.0, 0.3);
uniform vec4 color_right : source_color = vec4(0.0, 0.0, 0.2, 0.8);

// Control de suavidad y dirección
uniform float softness : hint_range(0.1, 3.0) = 1.0;
uniform float gradient_angle : hint_range(0.0, 360.0) = 0.0;
uniform bool invert_direction = false;

// Difuminado de bordes
uniform float edge_feather : hint_range(0.0, 0.5) = 0.1;
uniform bool feather_enabled = true;

// Efectos adicionales
uniform float brightness : hint_range(0.0, 2.0) = 1.0;
uniform float contrast : hint_range(0.0, 2.0) = 1.0;

void fragment() {
    // Calcular la posición en el degradado basado en el ángulo
    vec2 center = vec2(0.5, 0.5);
    vec2 dir = vec2(cos(radians(gradient_angle)), sin(radians(gradient_angle)));
    vec2 rel_pos = UV - center;
    float t = dot(rel_pos, dir) + 0.5;

    // Aplicar inversión si está activada
    if (invert_direction) {
        t = 1.0 - t;
    }

    // Aplicar suavidad y clamp
    t = pow(clamp(t, 0.0, 1.0), softness);

    // Mezclar colores
    vec4 final_color = mix(color_left, color_right, t);

    // Aplicar difuminado de bordes
    if (feather_enabled) {
        // Calcular distancia a los bordes
        vec2 edge_dist = min(UV, 1.0 - UV) / edge_feather;
        float alpha_mask = min(edge_dist.x, edge_dist.y);
        alpha_mask = clamp(alpha_mask, 0.0, 1.0);

        // Aplicar máscara de transparencia a los bordes
        final_color.a *= alpha_mask;
    }

    // Aplicar brillo y contraste
    final_color.rgb = ((final_color.rgb - 0.5) * contrast + 0.5) * brightness;
    final_color.rgb = clamp(final_color.rgb, 0.0, 1.0);

    COLOR = final_color;
}