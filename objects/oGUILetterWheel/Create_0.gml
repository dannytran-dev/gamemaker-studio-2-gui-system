/// @description Init
//-----------------------------------------------------------------------------
//	GUI LETTER WHEEL
//	Arcade-style character picker: click the top half (or scroll up) for the
//	next character, the bottom half for the previous one. Wraps around at
//	both ends. Line a few up for high score initials.
//
//	Variable Definitions:
//		letters		Characters to cycle through
//		index		Index of the current character (0 based)
//		onChange	function(letter, wheel) called when the character changes
//-----------------------------------------------------------------------------

event_inherited();

interactive_ = true;
pressedUp_ = false;		// Which half the button went down on

#region METHODS

get_letter = function() {
	return string_char_at(letters, index + 1);
}

/// Shows _letter if it's in the list (case-insensitive); returns false if it isn't
set_letter = function(_letter, _notify = false) {
	var _pos = string_pos(string_upper(_letter), string_upper(letters));
	if (_pos == 0) return false;
	set_index(_pos - 1, _notify);
	return true;
}

set_index = function(_index, _notify = true) {
	var _count = string_length(letters);
	_index = ((_index mod _count) + _count) mod _count;
	if (_index == index) return;

	index = _index;
	if (_notify && !is_undefined(onChange)) onChange(get_letter(), id);
}

/// Steps forwards (1) or backwards (-1) through the letters
spin = function(_direction) {
	set_index(index + _direction);
}

/// Is a GUI y coordinate on the top (next) half?
is_up_half = function(_y) {
	return _y < y;
}

on_press = function(_x, _y) {
	pressedUp_ = is_up_half(_y);
}

on_release = function(_x, _y, _isOver) {
	// Only counts if released on the same half it was pressed on
	if (_isOver && is_up_half(_y) == pressedUp_) spin(pressedUp_ ? 1 : -1);
}

draw_element = function() {
	var _theme = gui_theme();
	var _alpha = get_alpha();
	var _x1 = x - width / 2;
	var _y1 = y - height / 2;
	gui_draw_box(_x1, _y1, _x1 + width, _y1 + height, _theme.field, hovered_ ? _theme.accent : _theme.border, _alpha);

	// Arrows: highlighted on the half under the pointer
	var _overUp = hovered_ && is_up_half(gui_mouse_y());
	var _arrowW = width * 0.22;
	var _arrowH = width * 0.13;
	var _arrowY = height * 0.36;
	draw_set_alpha(_alpha);
	draw_set_colour(_overUp ? _theme.accent : _theme.textMuted);
	draw_triangle(x - _arrowW, y - _arrowY + _arrowH / 2, x + _arrowW, y - _arrowY + _arrowH / 2, x, y - _arrowY - _arrowH / 2, false);
	draw_set_colour((hovered_ && !_overUp) ? _theme.accent : _theme.textMuted);
	draw_triangle(x - _arrowW, y + _arrowY - _arrowH / 2, x + _arrowW, y + _arrowY - _arrowH / 2, x, y + _arrowY + _arrowH / 2, false);
	draw_set_alpha(1);

	gui_draw_label(x, y, get_letter(), _theme.text, _alpha, fa_center, fa_middle, _theme.textScale * 2);
}

#endregion

// Wrap the starting index into range without reporting it as a change
set_index(index, false);
