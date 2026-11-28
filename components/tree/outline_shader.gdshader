shader_type canvas_item;

uniform bool active = false;
uniform vec4 glow_color : source_color = vec4(1.0, 0.95, 0.7, 1.0); // Putih hangat bercahaya
uniform float glow_size : hint_range(0.0, 15.0) = 3.0; // Seberapa jauh cahaya menyebar
uniform float glow_intensity : hint_range(0.0, 3.0) = 1.5; // Kecerahan cahaya
uniform vec4 hit_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	col.rgb = mix(col.rgb, vec3(1.0, 0.15, 0.15), 1.0 - hit_tint.g);
	
	if (active) {
		float total_alpha = 0.0;
		float samples = 0.0;
		
		// Mengecek 3 lapisan jarak ke luar untuk membuat gradasi cahaya halus
		for (float r = 1.0; r <= 3.0; r += 1.0) {
			vec2 step_size = TEXTURE_PIXEL_SIZE * (glow_size * (r / 3.0));
			float weight = 1.0 / r; // Makin jauh dari pohon, cahaya makin redup
			
			total_alpha += texture(TEXTURE, UV + vec2(0.0, -step_size.y)).a * weight;
			total_alpha += texture(TEXTURE, UV + vec2(0.0, step_size.y)).a * weight;
			total_alpha += texture(TEXTURE, UV + vec2(-step_size.x, 0.0)).a * weight;
			total_alpha += texture(TEXTURE, UV + vec2(step_size.x, 0.0)).a * weight;
			total_alpha += texture(TEXTURE, UV + vec2(-step_size.x, -step_size.y)).a * weight;
			total_alpha += texture(TEXTURE, UV + vec2(step_size.x, -step_size.y)).a * weight;
			total_alpha += texture(TEXTURE, UV + vec2(-step_size.x, step_size.y)).a * weight;
			total_alpha += texture(TEXTURE, UV + vec2(step_size.x, step_size.y)).a * weight;
			
			samples += 8.0 * weight;
		}
		
		float glow = clamp((total_alpha / samples) * glow_intensity, 0.0, 1.0);
		
		// Campurkan pendaran cahaya lembut di area transparan di luar gambar pohon
		vec4 outer_glow = vec4(glow_color.rgb, glow * glow_color.a);
		col = mix(outer_glow, col, col.a);
	}
	
	COLOR = col;
}
