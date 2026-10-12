/// @description Init
//-----------------------------------------------------------------------------
//	GUI TEXT
//	A label. The text is aligned by its anchor, so text pinned to the right
//	edge grows to the left and text pinned to the bottom grows upwards.
//
//	Variable Definitions:
//		text		The string to draw
//		font		Font asset, or undefined for the theme font
//		colour		Text colour
//		scale		Text scale
//		maxWidth	Wrap width in GUI units; 0 doesn't wrap
//-----------------------------------------------------------------------------

event_inherited();

#region METHODS

set_text = function(_text) {
	text = string(_text);
}

draw_element = function() {
	draw_set_font(font ?? gui_theme().font);
	draw_set_colour(colour);
	draw_set_alpha(get_alpha());
	gui_set_align(anchor);

	if (maxWidth > 0) {
		draw_text_ext_transformed(x, y, text, -1, maxWidth / scale, scale, scale, image_angle);
	}
	else {
		draw_text_transformed(x, y, text, scale, scale, image_angle);
	}

	draw_set_alpha(1);
}

#endregion
