shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;
uniform float zoom : hint_range(0.1, 100.0) = 4.0;
uniform vec2 dreamsize = vec2(100.0, 100.0);
uniform float smoothness : hint_range(-1.0, 1.0) = 0.0;
uniform vec2 read_offset = vec2(0.0, 0.0);

vec3 valueInsideRect(vec2 p, vec4 rect, vec3 insideColor)
{
    float inX = step(rect.x, p.x) * step(p.x, rect.z);
    float inY = step(rect.y, p.y) * step(p.y, rect.w);
    float inside = inX * inY;   // 1.0 if inside, 0.0 if outside
	return inside * insideColor; // black (0,0,0) outside
}

vec2 clampedInsideRect(vec2 p, vec4 rect)
{
	return vec2(
		clamp(rect.x, p.x, rect.z),
		clamp(rect.y, p.y, rect.w)
	);
}

vec3 blend4(vec3[4] colours, float xw, float yw) {
	return mix(
		mix(colours[0], colours[1], xw),
		mix(colours[2], colours[3], xw),
		yw
	);
}
vec3 get_uncached_blended_xy_pixelcol(
	sampler2D screen_texture,
	vec2 screen_x1_int_uv,
	vec4 dreamrect_uv,
	vec2 p,
	float xw, float yw
) {
	vec2[4] pixeluvs = {
		screen_x1_int_uv,
		screen_x1_int_uv + vec2(p.x,0.),
		screen_x1_int_uv + vec2(0.,p.y),
		screen_x1_int_uv + p
	};
	vec3[4] colours;
	//for(int i=0;i<4;i++) { colours[i] = valueInsideRect(
		//pixeluvs[i],
		//dreamrect_uv,
		//texture(screen_texture, pixeluvs[i]).rgb
	//); }
	//for(int i=0;i<4;i++) { colours[i] =
		//texture(screen_texture, pixeluvs[i]).rgb;
	//}
	for(int i=0;i<4;i++) { colours[i] =
		texture(screen_texture,
			clampedInsideRect(pixeluvs[i], dreamrect_uv)
		).rgb;
	}
	return blend4(colours,xw,yw);
}

void fragment() {
	vec2 dreamsize_uv = (dreamsize - vec2(0.5)) * SCREEN_PIXEL_SIZE;
	vec2 top_left_corner_of_dream = (vec2(1.,1.) - dreamsize_uv * zoom)*0.5;
	vec2 screen_x1_uv = (SCREEN_UV - top_left_corner_of_dream) / zoom;
	vec2 screen_x1 = screen_x1_uv / SCREEN_PIXEL_SIZE;
	vec2 screen_x1_int = vec2(floor(screen_x1.x-0.5)+0.5, floor(screen_x1.y-0.5)+0.5); // rounded
	vec2 screen_x1_int_uv = screen_x1_int * SCREEN_PIXEL_SIZE;
	vec2 read_offset_uv = read_offset * SCREEN_PIXEL_SIZE;
	
	float xw = mix(screen_x1.x - screen_x1_int.x, smoothstep(0., 1., screen_x1.x - screen_x1_int.x), smoothness);
	float yw = mix(screen_x1.y - screen_x1_int.y, smoothstep(0., 1., screen_x1.y - screen_x1_int.y), smoothness);
	vec4 dreamrect_uv = vec4(0.0, 0.0, dreamsize_uv);
	
	COLOR.rgb = get_uncached_blended_xy_pixelcol(
		SCREEN_TEXTURE, screen_x1_int_uv + read_offset_uv, dreamrect_uv,
		SCREEN_PIXEL_SIZE, xw, yw);
}