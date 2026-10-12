/// @description Init
//-----------------------------------------------------------------------------
//	GUI BUTTON
//	Calls onClick when the left button is pressed and released over it.
//	Drawn as a themed box, or with a sprite skin (frames: normal, hover,
//	pressed; set up nine-slice on the sprite to stretch it cleanly).
//
//	Variable Definitions:
//		label		Text on the button
//		primary		Filled with the accent colour (the main action)
//		skin		Sprite to draw instead of the themed box, or undefined
//		onClick		function(button) called on click
//-----------------------------------------------------------------------------

event_inherited();

interactive_ = true;
scale_ = 1;		// Eases towards a hover / press scale in Step

#region METHODS

set_label = function(_label) {
	label = string(_label);
}

on_release = function(_x, _y, _isOver) {
	if (_isOver && !is_undefined(onClick)) onClick(id);
}

draw_element = function() {
	var _theme = gui_theme();
	var _alpha = get_alpha();
	var _w = width * scale_;
	var _h = height * scale_;
	var _x1 = x - _w / 2;
	var _y1 = y - _h / 2;
	var _down = pressed_ && hovered_;

	if (!is_undefined(skin)) {
		var _frame = min(_down ? 2 : (hovered_ ? 1 : 0), sprite_get_number(skin) - 1);
		draw_sprite_stretched_ext(skin, _frame, _x1, _y1, _w, _h, c_white, _alpha);
	}
	else if (primary) {
		var _fill = hovered_ ? merge_colour(_theme.accent, c_white, 0.2) : _theme.accent;
		gui_draw_box(_x1, _y1, _x1 + _w, _y1 + _h, _fill, _fill, _alpha);
	}
	else {
		gui_draw_box(_x1, _y1, _x1 + _w, _y1 + _h, hovered_ ? _theme.panelHover : _theme.panel, hovered_ ? _theme.accent : _theme.border, _alpha);
	}

	var _textColour = (primary && is_undefined(skin)) ? _theme.accentText : _theme.text;
	gui_draw_label(x, y, label, _textColour, _alpha, fa_center, fa_middle, _theme.textScale * scale_);
}

#endregion
