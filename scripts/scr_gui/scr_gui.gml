//-----------------------------------------------------------------------------
//	GUI SYSTEM
//-----------------------------------------------------------------------------
//	Public API. Elements are objects (children of oGUIElement) that can be
//	placed in a room or created from code with gui_create(). oGUIManager is
//	created automatically by the first element and does the rest:
//		- draws every element in Draw GUI, in creation order
//		- routes the pointer to the topmost element under it
//		- tracks keyboard focus
//		- re-anchors elements whenever the display scaler fires RESIZE
//		- keeps the stack of open menus (see scr_gui_menu)
//-----------------------------------------------------------------------------

///
/// @function				gui_manager()
/// @description            Returns the GUI manager, creating it if it doesn't exist yet.
///
/// @returns {Id.Instance}
///
function gui_manager() {
	if (instance_exists(oGUIManager)) return oGUIManager.id;
	return instance_create_depth(0, 0, GUI_DEPTH, oGUIManager);
}

///
/// @function				gui_create(_object, _x, _y, [_vars])
/// @description            Creates a GUI element. The position is in BASE_WIDTH x BASE_HEIGHT
///							space and is the element's centre (text elements align to it
///							according to their anchor).
///
///							_vars sets the element's Variable Definitions before its Create
///							event runs, e.g.
///								gui_create(oGUIButton, 960, 540, { label: "Play", onClick: start_game });
///
/// @param {Asset.GMObject}	[_object] - oGUIElement or one of its children.
/// @param {Real}			[_x] - The x position in BASE space.
/// @param {Real}			[_y] - The y position in BASE space.
/// @param {Struct}			[_vars] - Variable values to apply before the Create event.
/// @returns {Id.Instance}
///
function gui_create(_object, _x, _y, _vars = {}) {
	return instance_create_depth(_x, _y, 0, _object, _vars);
}

///
/// @function				gui_focus(_element)
/// @description            Gives keyboard focus to an element (e.g. an input field), or clears
///							it when passed noone.
///
/// @param {Id.Instance}	[_element] - The element to focus, or noone.
/// @returns {undefined}
///
function gui_focus(_element) {
	gui_manager().set_focus(_element);
}

///
/// @function				gui_get_focus()
/// @description            Returns the element that has keyboard focus, or noone.
///
/// @returns {Id.Instance}
///
function gui_get_focus() {
	return instance_exists(oGUIManager) ? oGUIManager.focused_ : noone;
}

///
/// @function				gui_is_mouse_over()
/// @description            True while the pointer is over an interactive element (or a menu
///							that blocks input). Use it to stop game clicks going through the UI.
///
/// @returns {Bool}
///
function gui_is_mouse_over() {
	return instance_exists(oGUIManager) && oGUIManager.hovered_ != noone;
}

///
/// @function				gui_mouse_x()
/// @description            Pointer x in GUI space (corrected for the device pixel ratio).
///
/// @returns {Real}
///
function gui_mouse_x() {
	return instance_exists(oGUIManager) ? oGUIManager.mouseX_ : display_mouse_gui_x();
}

///
/// @function				gui_mouse_y()
/// @description            Pointer y in GUI space (corrected for the device pixel ratio).
///
/// @returns {Real}
///
function gui_mouse_y() {
	return instance_exists(oGUIManager) ? oGUIManager.mouseY_ : display_mouse_gui_y();
}

///
/// @function				gui_relayout()
/// @description            Re-anchors every element to the current GUI size. Runs on its own
///							when the display scaler fires DisplayScalerEvent.RESIZE.
///
/// @returns {undefined}
///
function gui_relayout() {
	with (oGUIManager) {
		relayout();
	}
}

///
/// @function				gui_bring_to_front(_element)
/// @description            Draws an element above all others and gives it input priority.
///
/// @param {Id.Instance}	[_element] - The element to move.
/// @returns {undefined}
///
function gui_bring_to_front(_element) {
	with (oGUIManager) {
		bring_to_front(_element);
	}
}

///
/// @function				gui_set_align(_anchor)
/// @description            Sets the text alignment that matches an anchor, so text anchored
///							to the right edge grows to the left, and so on.
///
/// @param {Real}			[_anchor] - A DisplayAnchor value.
/// @returns {undefined}
///
function gui_set_align(_anchor) {
	static _halign = [fa_left, fa_center, fa_right];
	static _valign = [fa_top, fa_middle, fa_bottom];
	draw_set_halign(_halign[_anchor mod 3]);
	draw_set_valign(_valign[_anchor div 3]);
}

///
/// @function				gui_draw_box(_x1, _y1, _x2, _y2, _fill, _border, _alpha, [_radius])
/// @description            Draws a filled rounded box with a 1px border.
///
/// @param {Real}			[_x1] - Left.
/// @param {Real}			[_y1] - Top.
/// @param {Real}			[_x2] - Right.
/// @param {Real}			[_y2] - Bottom.
/// @param {Constant.Colour}	[_fill] - Fill colour.
/// @param {Constant.Colour}	[_border] - Border colour.
/// @param {Real}			[_alpha] - Opacity, 0 to 1.
/// @param {Real}			[_radius] - Corner radius (default: theme radius).
/// @returns {undefined}
///
function gui_draw_box(_x1, _y1, _x2, _y2, _fill, _border, _alpha, _radius = gui_theme().radius) {
	var _d = _radius * 2;
	draw_set_alpha(_alpha);
	draw_set_colour(_fill);
	draw_roundrect_ext(_x1, _y1, _x2, _y2, _d, _d, false);
	draw_set_colour(_border);
	draw_roundrect_ext(_x1, _y1, _x2, _y2, _d, _d, true);
	draw_set_alpha(1);
}

///
/// @function				gui_draw_label(_x, _y, _text, _colour, _alpha, [_halign], [_valign], [_scale])
/// @description            Draws a single line of text in the theme font.
///
/// @param {Real}			[_x] - The x position.
/// @param {Real}			[_y] - The y position.
/// @param {String}			[_text] - The text to draw.
/// @param {Constant.Colour}	[_colour] - Text colour.
/// @param {Real}			[_alpha] - Opacity, 0 to 1.
/// @param {Constant.HAlign}	[_halign] - Horizontal alignment (default centre).
/// @param {Constant.VAlign}	[_valign] - Vertical alignment (default middle).
/// @param {Real}			[_scale] - Text scale (default: theme textScale).
/// @returns {undefined}
///
function gui_draw_label(_x, _y, _text, _colour, _alpha, _halign = fa_center, _valign = fa_middle, _scale = gui_theme().textScale) {
	draw_set_font(gui_theme().font);
	draw_set_halign(_halign);
	draw_set_valign(_valign);
	draw_set_colour(_colour);
	draw_set_alpha(_alpha);
	draw_text_transformed(_x, _y, _text, _scale, _scale, 0);
	draw_set_alpha(1);
}
