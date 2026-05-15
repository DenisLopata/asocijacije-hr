shader_type canvas_item;
void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float v = dot(uv, uv);
	float alpha = smoothstep(0.4, 1.6, v) * 0.50;
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
