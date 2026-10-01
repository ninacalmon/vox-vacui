shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

uniform vec2 center = vec2(0.5, 0.5);
uniform float radius = 0.25;
uniform float falloff = 0.5;
uniform float distortion_strength = 0.02;
uniform float speed = 0.5;
uniform float scale = 80.0;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x)
         + (c - a) * u.y * (1.0 - u.x)
         + (d - b) * u.x * u.y;
}

void fragment() {
    vec2 uv = SCREEN_UV;

    float dist = distance(UV, center);
    float mask = 1.0 - smoothstep(radius * falloff, radius, dist);

    vec2 n_uv = uv * scale + vec2(0.0, TIME * speed);

    float n1 = noise(n_uv);
    float n2 = noise(n_uv + vec2(100.0));

    vec2 distortion = vec2(n1 - 0.5, n2 - 0.5);

    vec2 distorted_uv = uv + distortion * distortion_strength * mask;

    vec4 screen_color = texture(screen_texture, distorted_uv);

    COLOR = vec4(screen_color.rgb, texture(TEXTURE, UV).a * COLOR.a);
}
//shader_type canvas_item; // AI vvvvvv
//
//// This tells Godot to look at the screen behind the sprite
//uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
//
//uniform vec2 center = vec2(0.5, 0.5);
//uniform float radius = 0.25;
//uniform float falloff = 0.5;
//uniform float distortion_strength = 0.02;
//uniform float speed = 0.5;
//uniform float scale = 80.0;
//
//float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
//float noise(vec2 p) {
    //vec2 i = floor(p); vec2 f = fract(p);
    //float a = hash(i); float b = hash(i + vec2(1.0, 0.0));
    //float c = hash(i + vec2(0.0, 1.0)); float d = hash(i + vec2(1.0, 1.0));
    //vec2 u = f * f * (3.0 - 2.0 * f);
    //return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
//}
//
//void fragment() {
    //// We use SCREEN_UV so it samples the game world behind it
    //vec2 uv = SCREEN_UV;
//
    //// Use standard UV just for calculating the center of THIS sprite
    //float dist = distance(UV, center);
    //float mask = 1.0 - smoothstep(radius * falloff, radius, dist);
//
    //vec2 n_uv = uv * scale + vec2(0.0, TIME * speed);
    //float n1 = noise(n_uv);
    //float n2 = noise(n_uv + 100.0);
    //vec2 distortion = vec2(n1 - 0.5, n2 - 0.5);
//
    //vec2 distorted_uv = uv + distortion * distortion_strength * mask;
//
    //// Fetch the background screen color
    //vec4 screen_color = texture(screen_texture, distorted_uv);
    //
    //// Mix it with the sprite's alpha so the effect matches the sprite's shape
    //COLOR = vec4(screen_color.rgb, texture(TEXTURE, UV).a * COLOR.a);
//}