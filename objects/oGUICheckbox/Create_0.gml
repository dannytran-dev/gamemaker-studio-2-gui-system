/// @description Init
//-----------------------------------------------------------------------------
//	GUI CHECKBOX
//	A tick box with a label to its right. The whole width x height area is
//	clickable, label included.
//
//	Variable Definitions:
//		checked		Current state
//		label		Text next to the box
//		onChange	function(checked, checkbox) called when the state changes
//-----------------------------------------------------------------------------

event_inherited();

interactive_ = true;

#region METHODS

/// Sets the state; calls onChange if it changed and _notify is true
set_checked = function(_checked, _notify = true) {
	_checked = bool(_checked);
	if (_checked == checked) return;

	checked = _checked;
	if (_notify && !is_undefined(onChange)) onChange(checked, id);
}

on_release = function(_x, _y, _isOver) {
	if (_isOver) set_checked(!checked);
}

draw_element = function() {
	var _theme = gui_theme();
	var _alpha = get_alpha();
	var _size = height * 0.75;
	var _x1 = x - width / 2;
	var _y1 = y - _size / 2;
	var _x2 = _x1 + _size;
	var _y2 = _y1 + _size;

	if (checked) {
		gui_draw_box(_x1, _y1, _x2, _y2, _theme.accent, _theme.accent, _alpha, _theme.radius / 2);

		// Tick
		draw_set_colour(_theme.accentText);
		draw_set_alpha(_alpha);
		var _w = max(3, _size * 0.1);
		draw_line_width(_x1 + _size * 0.24, _y1 + _size * 0.52, _x1 + _size * 0.43, _y1 + _size * 0.71, _w);
		draw_line_width(_x1 + _size * 0.43, _y1 + _size * 0.71, _x1 + _size * 0.78, _y1 + _size * 0.31, _w);
		draw_set_alpha(1);
	}
	else {
		gui_draw_box(_x1, _y1, _x2, _y2, _theme.field, hovered_ ? _theme.accent : _theme.border, _alpha, _theme.radius / 2);
	}

	gui_draw_label(_x2 + 18, y, label, hovered_ ? _theme.text : _theme.textMuted, _alpha, fa_left, fa_middle);
}

#endregion
