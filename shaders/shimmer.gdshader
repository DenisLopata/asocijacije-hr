shader_type canvas_item;

uniform float spawn_time        = 0.0;
uniform float sparkle_intensity = 0.0;

void fragment() {
	float age = TIME - spawn_time;

	// One-shot diagonal sweep (first 1.0s)
	float diag       = UV.x * 0.65 + UV.y * 0.35;
	float sweep_dist = diag - age / 1.0;
	float sweep      = exp(-sweep_dist * sweep_dist * 28.0)
	                 * smoothstep(1.0, 0.3, age) * 0.18;

	// Slow breathing (permanent)
	float glow = (sin(TIME * 0.7 + 1.2) * 0.5 + 0.5) * 0.022;

	// Star twinkles — tight gaussian + fast sharp flicker
	float sparks = 0.0;
	if (sparkle_intensity > 0.001) {
		for (int i = 0; i < 8; i++) {
			float fi    = float(i);
			float speed = 1.2 + fi * 0.4;
			float px    = fract(sin(fi * 127.1 + 43.2) * 4375.5);
			float py    = fract(sin(fi * 311.7 + 12.8) * 5765.1);
			float life  = sin(fract(TIME * speed + fi * 0.618) * 3.14159);
			float dx    = UV.x - px;
			float dy    = UV.y - py;
			sparks += exp(-(dx*dx + dy*dy) * 4500.0) * life * life * life;
		}
		sparks *= sparkle_intensity * 0.35;
	}

	// Add brightness on top of the existing stylebox color
	COLOR.rgb += sweep + glow + sparks;
}
