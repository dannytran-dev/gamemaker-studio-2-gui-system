/// @description Init
//-----------------------------------------------------------------------------
//	GUI ELEMENT
//	Base object of the GUI system. GameMaker never draws it directly:
//	oGUIManager calls draw_element() in Draw GUI and sends it pointer input.
//
//	Layout: x / y start out in BASE_WIDTH x BASE_HEIGHT space and mark the
//	element's centre. layout() moves the element to the matching spot on the
//	current screen with display_gui_anchor_x/y, keeping its distance from the
//	edge (or centre) named by `anchor`. Anything that moves the element should
//	go through set_position() so the BASE position is kept.
//
//	Variable Definitions (set in the Room Editor or through gui_create's
//	_vars struct):
//		anchor		DisplayAnchor the element is pinned to
//		width		Size in GUI units (also the hit box)
//		height
//		enabled		Disabled elements are drawn faded and ignore input
//
//	Children override the methods below after calling event_inherited().
//-----------------------------------------------------------------------------

baseX_			= x;		// Position in BASE space
baseY_			= y;
menu_			= noone;	// oGUIMenu this element belongs to
order_			= 0;		// Draw order, set by the manager

interactive_	= false;	// Children that take pointer input set this
focusable_		= false;	// Children that take keyboard input set this
hovered_		= false;	// Topmost interactive element under the pointer
pressed_		= false;	// Left button went down on this element and hasn't been released

#region METHODS

/// Moves the element to a new BASE-space position
set_position = function(_x, _y) {
	baseX_ = _x;
	baseY_ = _y;
	layout();
}

/// Re-anchors the element to the current GUI size
layout = function() {
	x = display_gui_anchor_x(baseX_, anchor);
	y = display_gui_anchor_y(baseY_, anchor);
}

/// True if the element is visible and so is the menu it belongs to
is_shown = function() {
	if (!visible) return false;
	return (menu_ == noone) || (instance_exists(menu_) && menu_.visible);
}

/// True if the element should receive pointer input
can_interact = function() {
	return interactive_ && enabled && is_shown();
}

/// True if this element has keyboard focus
is_focused = function() {
	return gui_get_focus() == id;
}

/// The menu this element belongs to, or noone
get_menu = function() {
	return menu_;
}

/// Hit box in GUI space: width x height around x / y
hit_test = function(_x, _y) {
	var _hw = width / 2;
	var _hh = height / 2;
	return point_in_rectangle(_x, _y, x - _hw, y - _hh, x + _hw, y + _hh);
}

/// Opacity to draw with: image_alpha, faded while disabled
get_alpha = function() {
	return image_alpha * (enabled ? 1 : gui_theme().disabledAlpha);
}

/// Called by the manager in Draw GUI
draw_element = function() {}

// Input hooks, called by the manager in Begin Step:
on_hover	= function(_isOver) {}				// Pointer entered (true) or left (false)
on_press	= function(_x, _y) {}				// Left button went down on the element
on_drag		= function(_x, _y) {}				// Button still held, wherever the pointer is
on_release	= function(_x, _y, _isOver) {}		// Button came up; _isOver means it's a click
on_focus	= function(_isFocused) {}			// Keyboard focus gained or lost

#endregion

gui_manager().register(id);
