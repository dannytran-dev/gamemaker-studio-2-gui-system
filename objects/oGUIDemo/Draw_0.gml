/// @description World
// Drawn in the room, so the camera zoom affects it. The GUI is drawn on top
// by oGUIManager and keeps its size.

// Grid, filling whatever the screen shows outside the safe area
var _cell = 120;
var _x1 = -BASE_WIDTH * 2;
var _x2 = BASE_WIDTH * 3;
var _y1 = -BASE_HEIGHT * 2;
var _y2 = BASE_HEIGHT * 3;

draw_set_colour(colGrid_);
for (var _x = _x1; _x <= _x2; _x += _cell) draw_line(_x, _y1, _x, _y2);
for (var _y = _y1; _y <= _y2; _y += _cell) draw_line(_x1, _y, _x2, _y);

// Safe area
draw_set_colour(colSafe_);
draw_rectangle(0, 0, BASE_WIDTH, BASE_HEIGHT, false);
draw_set_colour(colAccent_);
draw_rectangle(0, 0, BASE_WIDTH, BASE_HEIGHT, true);

// Orbiting dots behind the menu
var _cx = BASE_WIDTH / 2;
var _cy = BASE_HEIGHT / 2;
draw_set_circle_precision(24);
for (var i = 0; i < 8; i++) {
	var _a = time_ * 0.4 + i * (pi / 4);
	draw_set_colour(i mod 2 == 0 ? colAccent_ : colWarm_);
	draw_circle(_cx + cos(_a) * 520, _cy + sin(_a) * 340, 18, false);
}

draw_set_colour(c_white);
