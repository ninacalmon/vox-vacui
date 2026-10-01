shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform sampler2D curve;
uniform float strenght : hint_range(-1, 1) = 0.5;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 vecToCenter = vec2(0.5, 0.5) - UV;
	float distToCenter = length(vecToCenter);
	float curveVal = texture(curve, vec2(distToCenter)).r;
	vec2 diff = normalize(vecToCenter) * strenght * curveVal;
	COLOR = texture(screen_texture, SCREEN_UV - diff);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
