shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float pixel_size : hint_range(1.0, 64.0) = 4.0;
uniform vec2 camera_pos;

void fragment() {
	vec2 resolution = vec2(textureSize(screen_texture, 0));

	vec2 uv = SCREEN_UV * resolution;
	vec2 world_uv = uv + camera_pos;

	vec2 snapped = floor(world_uv / pixel_size) * pixel_size;

	vec2 final_uv = (snapped - camera_pos) / resolution;

	COLOR = texture(screen_texture, final_uv);
}
