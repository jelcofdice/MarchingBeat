extends Resource
class_name Constants
const team_colors = {
	0: Color(0.35, 0.35, 0.8, 1),
	1: Color(0.7, 0.2, 0.2, 1),
	-1: Color(0.5, 0.5, 0.5, 1) # Neutral
}
const team_control_inputs = {
	0: {
		"player1_up": 0,
		"player1_right": 1,
		"player1_down": 2,
		"player1_left": 3,
	},
	1: {
		"player2_up": 0,
		"player2_right": 1,
		"player2_down": 2,
		"player2_left": 3,
	},
}
const number_direction_map = {
	0: Vector2i.UP,
	1: Vector2i.RIGHT,
	2: Vector2i.DOWN,
	3: Vector2i.LEFT,
}
const number_direction_map_inverse = {
	Vector2i.UP: 0,
	Vector2i.RIGHT: 1,
	Vector2i.DOWN: 2,
	Vector2i.LEFT: 3,
}