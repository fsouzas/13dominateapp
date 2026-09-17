// Original Shader By Zacksly
// https://zacksly.itch.io/
//
// Modified for a diagonal halftone loading transition.
// Original halftone shader logic and concept credited to Zacksly.

shader_type canvas_item;

uniform bool TransparentDot = true;
uniform float AspectRatio = 1.5;
uniform float Dots = 10.0;
uniform float _min = 0.0;
uniform float _max = 1.0;

uniform vec4 color : source_color = vec4(1.0);

uniform float progress : hint_range(0.0, 1.0) = 0.0;


void fragment() {

	vec3 uv_grid = fract(
		vec3(UV, 0.0) *
		vec3(AspectRatio * Dots, Dots, 0.0)
	);

	float grid = distance(
		uv_grid,
		vec3(0.5, 0.5, 0.5)
	);

	float diagonal = UV.x + UV.y;

	float amount;

	if (progress <= 0.5) {

		float phase = progress * 2.0;

		float front = mix(-1.0, 3.0, phase);

		amount = clamp(
			front - diagonal,
			0.0,
			1.0
		);

	} else {

		float phase = (progress - 0.5) * 2.0;

		float back = mix(-1.0, 3.0, phase);

		amount = clamp(
			diagonal - back + 1.0,
			0.0,
			1.0
		);
	}

	vec3 grayscale = vec3(amount);

	vec3 clamped = clamp(
		grayscale,
		vec3(_min),
		vec3(_max)
	);

	bool black_dot_grid =
		grid >
		dot(
			vec3(1.0) - clamped,
			vec3(0.333333)
		);

	bool white_dot_grid =
		grid <
		dot(
			clamped,
			vec3(0.333333)
		);


	bool visible_dot;

	if (TransparentDot) {
		visible_dot = black_dot_grid;
	} else {
		visible_dot = white_dot_grid;
	}

	if (visible_dot) {
		COLOR = color;
	} else {
		COLOR = vec4(0.0);
	}
}