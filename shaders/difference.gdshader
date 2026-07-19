shader_type canvas_item;

// Captura exatamente o que está renderizado atrás da UI
uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);
    
    // 2. Pega a cor do pixel do fundo/jogo (Camada de Baixo)
    vec4 screen_color = texture(screen_texture, SCREEN_UV);
    
    vec3 blend_difference = abs(screen_color.rgb - texture_color.rgb);
    
    COLOR = vec4(blend_difference, texture_color.a);
}
