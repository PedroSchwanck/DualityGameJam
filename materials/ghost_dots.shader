shader_type canvas_item;

uniform float scale = 4.0;   // tamanho dos pontos (maior = pontos mais espaçados)
uniform float alpha  = 0.35; // transparência dos pontos

void fragment() {
    // padrão simples de tabuleiro (checker)
    vec2 uv = FRAGCOORD.xy / scale;
    int cx = int(floor(uv.x));
    int cy = int(floor(uv.y));
    bool dot = ((cx + cy) % 2) == 0;

    vec4 base = texture(TEXTURE, UV);
    if (dot) {
        // mistura com a cor base, deixando aspecto pontilhado
        COLOR = vec4(base.rgb, alpha);
    } else {
        discard; // “buraco” entre os pontos
    }
}
