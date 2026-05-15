shader_type canvas_item;
void fragment() {
	vec2 uv = UV;
	float t = TIME * 0.05;

	vec3 base = mix(vec3(0.08, 0.09, 0.14), vec3(0.04, 0.04, 0.08), uv.y);

	vec2 p1 = vec2(0.20 + sin(t * 0.71) * 0.10, 0.18 + cos(t * 0.53) * 0.08);
	vec2 p2 = vec2(0.78 + cos(t * 0.67) * 0.09, 0.52 + sin(t * 0.41) * 0.13);
	vec2 p3 = vec2(0.48 + sin(t * 0.37) * 0.07, 0.82 + cos(t * 0.29) * 0.05);

	float b1 = smoothstep(0.50, 0.0, length(uv - p1));
	float b2 = smoothstep(0.45, 0.0, length(uv - p2));
	float b3 = smoothstep(0.38, 0.0, length(uv - p3));

	vec3 col = base;
	col += vec3(0.10, 0.05, 0.25) * b1 * 0.20;
	col += vec3(0.03, 0.10, 0.24) * b2 * 0.16;
	col += vec3(0.15, 0.04, 0.18) * b3 * 0.14;

	COLOR = vec4(col, 1.0);
}
