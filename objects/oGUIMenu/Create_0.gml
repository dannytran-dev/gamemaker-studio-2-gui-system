/// @description Init
//-----------------------------------------------------------------------------
//	GUI MENU
//	A screen or dialog that owns a group of elements. Elements added with
//	add() are positioned relative to the menu and share its anchor, so the
//	whole menu stays together when the screen is resized. They are hidden
//	with the menu and destroyed with it.
//
//	Variable Definitions:
//		title		Drawn at the top of the panel
//		width		Panel size; 0 x 0 draws no panel
//		height
//		overlay		Dim the screen and block input to everything below
//		hideBelow	Hide the menus underneath while this one is open
//		dismissable	Esc or a click outside the panel closes the menu
//		build		function(menu) called at the end of Create to add elements
//
//	Open menus with gui_menu_open() so they stack (see scr_gui_menu).
//-----------------------------------------------------------------------------

event_inherited();

interactive_	= true;		// Absorbs clicks on the panel / overlay
elements_		= [];

#region METHODS

/// Creates an element that belongs to this menu. _x / _y are relative to the
/// menu's centre; the element uses the menu's anchor unless _vars sets one.
add = function(_object, _x, _y, _vars = {}) {
	if (!variable_struct_exists(_vars, "anchor")) _vars.anchor = anchor;

	var _element = gui_create(_object, baseX_ + _x, baseY_ + _y, _vars);
	_element.menu_ = id;
	array_push(elements_, _element);
	return _element;
}

/// Closes this menu (and destroys its elements)
close = function() {
	gui_menu_close(id);
}

has_panel = function() {
	return width > 0 && height > 0;
}

in_panel = function(_x, _y) {
	return has_panel() && point_in_rectangle(_x, _y, x - width / 2, y - height / 2, x + width / 2, y + height / 2);
}

hit_test = function(_x, _y) {
	return overlay || in_panel(_x, _y);
}

on_release = function(_x, _y, _isOver) {
	if (_isOver && dismissable && !in_panel(_x, _y)) close();
}

draw_element = function() {
	var _theme = gui_theme();

	if (overlay) {
		draw_set_colour(_theme.overlay);
		draw_set_alpha(_theme.overlayAlpha * image_alpha);
		draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
		draw_set_alpha(1);
	}

	if (has_panel()) {
		var _x1 = x - width / 2;
		var _y1 = y - height / 2;
		gui_draw_box(_x1, _y1, x + width / 2, y + height / 2, _theme.panel, _theme.border, image_alpha, _theme.radius * 1.5);

		if (title != "") {
			gui_draw_label(x, _y1 + 52, title, _theme.text, image_alpha, fa_center, fa_middle, _theme.textScale * 1.3);
		}
	}
}

#endregion

gui_manager().push_menu(id);

if (!is_undefined(build)) {
	build(id);
}
