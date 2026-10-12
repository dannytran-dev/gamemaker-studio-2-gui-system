/// @description Init
//-----------------------------------------------------------------------------
//	GUI IMAGE
//	Draws a sprite centred on the element. With a width and/or height it is
//	scaled to fit inside that box, keeping its aspect ratio.
//
//	Variable Definitions:
//		sprite		Sprite asset to draw (undefined draws nothing)
//		frame		Sub-image to draw
//		colour		Blend colour
//		width		Box to fit the sprite in; 0 x 0 draws it at its own size,
//		height		and one of the two scales by that side only
//-----------------------------------------------------------------------------

event_inherited();

#region METHODS

set_sprite = function(_sprite, _frame = 0) {
	sprite = _sprite;
	frame = _frame;
}

/// Scale that fits the sprite inside width x height
get_fit_scale = function() {
	var _sw = sprite_get_width(sprite);
	var _sh = sprite_get_height(sprite);
	if (width > 0 && height > 0) return min(width / _sw, height / _sh);
	if (width > 0) return width / _sw;
	if (height > 0) return height / _sh;
	return 1;
}

draw_element = function() {
	if (is_undefined(sprite) || !sprite_exists(sprite)) return;

	var _scale = get_fit_scale();
	var _xscale = _scale * image_xscale;
	var _yscale = _scale * image_yscale;

	// Centre the image on x / y whatever the sprite's origin is
	var _x = x + (sprite_get_xoffset(sprite) - sprite_get_width(sprite) / 2) * _xscale;
	var _y = y + (sprite_get_yoffset(sprite) - sprite_get_height(sprite) / 2) * _yscale;
	draw_sprite_ext(sprite, frame, _x, _y, _xscale, _yscale, 0, colour, get_alpha());
}

#endregion
