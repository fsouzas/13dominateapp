shader_type canvas_item;

// Agora você só precisa passar a nova cor!
uniform vec4 replace_color : source_color;

void fragment() {
    vec4 current_color = texture(TEXTURE, UV);
    
    // Multiplica os canais RGB da imagem pela sua nova cor.
    // O branco (#ffffff) vai virar a cor exata. 
    // As sombras (cinzas) vão virar sombras perfeitas da nova cor.
    vec3 final_rgb = current_color.rgb * replace_color.rgb;
    
    // Mantém a transparência (alpha) original da imagem
    COLOR = vec4(final_rgb, current_color.a);
}
