shader_type canvas_item;

instance uniform bool enabled = true;
instance uniform vec4 outline_color : source_color = vec4(0.55, 0.16, 0.17, 1.0);
instance uniform int outline_width = 1;
uniform bool rounded = true;
uniform float alpha_threshold = 0.1;

void fragment() {
	vec4 base = texture(TEXTURE, UV);

	if (!enabled) {
		COLOR = base;
	} else {
		vec2 pixel = TEXTURE_PIXEL_SIZE;
		
		// 1. Check if the current pixel is part of the main artwork
		bool is_base = base.a > alpha_threshold;
		float max_alpha = 0.0;

		if (!is_base) {
			// 2. High-performance multi-direction sample for smooth art
			// Instead of checking 400+ points on high-res textures, we look in 8 directions
			vec2 directions[8] = vec2[](
				vec2(1.0, 0.0), vec2(-1.0, 0.0), vec2(0.0, 1.0), vec2(0.0, -1.0),
				vec2(0.707, 0.707), vec2(-0.707, 0.707), vec2(0.707, -0.707), vec2(-0.707, -0.707)
			);

			float width_f = float(outline_width);

			for (int i = 0; i < 8; i++) {
				vec2 offset = directions[i] * width_f * pixel;
				float sample_alpha = texture(TEXTURE, UV + offset).a;
				max_alpha = max(max_alpha, sample_alpha);
			}
		}

		// 3. Render and Blend smoothly
		if (is_base) {
			COLOR = base;
		} else if (max_alpha > alpha_threshold) {
			// Anti-aliasing step: blends the outline smoothly based on the edge alpha
			float outline_factor = smoothstep(alpha_threshold, 1.0, max_alpha);
			COLOR = vec4(outline_color.rgb, outline_color.a * outline_factor);
		} else {
			COLOR = vec4(0.0);
		}
	}
}
//shader_type canvas_item;
//
//instance uniform bool enabled = true;
//instance uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
//instance uniform int outline_width = 1;
//uniform bool rounded = true;
//uniform float alpha_threshold = 0.1;
//
//void fragment() {
	//vec4 base = texture(TEXTURE, UV);
//
	//if (!enabled) {
		//COLOR = base;
	//} else {
//
//
	//vec2 pixel = TEXTURE_PIXEL_SIZE;
//
	//bool is_base = base.a > alpha_threshold;
	//bool found = false;
//
	//if (!is_base) {
		//for (int x = -10; x <= 10; x++) {
			//if (x < -outline_width || x > outline_width) continue;
//
			//for (int y = -10; y <= 10; y++) {
				//if (y < -outline_width || y > outline_width) continue;
				//if (rounded && length(vec2(float(x), float(y))) > float(outline_width)) continue;
//
				//vec2 offset = vec2(float(x), float(y)) * pixel;
//
				//if (texture(TEXTURE, UV + offset).a > alpha_threshold) {
					//found = true;
					//break;
				//}
			//}
			//if (found) break;
		//}
	//}
//
	//if (is_base) {
		//COLOR = base;
	//} else if (found) {
		//COLOR = outline_color;
	//} else {
		//COLOR = vec4(0.0);
	//}
	//}
//}