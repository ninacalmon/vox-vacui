shader_type canvas_item;

uniform float inflate : hint_range(0.0, 0.6) = 0.0;
uniform float radius : hint_range(0.0, 1.0) = 0.5;
uniform float softness : hint_range(0.01, 1.0) = 0.3;

uniform vec4 inflate_color : source_color = vec4(1.0, 0.5, 0.5, 1.0);
uniform float color_strength : hint_range(0.0, 3.0) = 1.0;

uniform vec4 tint_color : source_color = vec4(1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 center = vec2(0.5);
    vec2 dir = UV - center;
    float dist = length(dir);

    float mask = smoothstep(radius, radius - softness, dist);

    vec2 offset = normalize(dir) * inflate * mask * 0.2;
    vec2 uv = UV - offset;

    vec4 tex = texture(TEXTURE, uv);

    float influence = inflate * mask * color_strength;

    vec3 final_color = mix(tex.rgb, tex.rgb * inflate_color.rgb, influence);

    final_color = mix(final_color, tint_color.rgb, tint_strength);

    COLOR = vec4(final_color, tex.a);
}