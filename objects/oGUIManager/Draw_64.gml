/// @description Draw Elements

for (var i = 0; i < array_length(elements_); i++) {
	var _element = elements_[i];
	if (instance_exists(_element) && _element.is_shown()) {
		_element.draw_element();
	}
}

// Leave the draw state as GameMaker's defaults for anything drawn after the GUI
draw_set_alpha(1);
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
