shader_type canvas_item;

varying vec4 modulate_color;

uniform float pixel_size : hint_range(1.0, 64.0) = 8.0;

void vertex() {
    modulate_color = COLOR;
}

void fragment() {
    vec2 tex_size = vec2(textureSize(TEXTURE, 0));

    vec2 snapped_uv =
        floor(UV * tex_size / pixel_size) *
        pixel_size / tex_size;

    vec4 tex = texture(TEXTURE, snapped_uv);

    COLOR = tex * modulate_color;
}