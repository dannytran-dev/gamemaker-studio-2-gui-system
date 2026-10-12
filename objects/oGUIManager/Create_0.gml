/// @description Init
//-----------------------------------------------------------------------------
//	GUI MANAGER
//	Created by the first GUI element in a room (see gui_manager()). There is
//	never more than one.
//
//	- Draw GUI: draws every element in creation order (back to front).
//	- Begin Step: finds the topmost interactive element under the pointer and
//	  sends it hover / press / drag / release, before any element's Step runs.
//	  The element the button went down on keeps receiving drag and release
//	  until the button comes up, even if the pointer leaves it.
//	- Keyboard focus: one element at a time (input fields). Esc clears focus,
//	  or closes the top menu if it is dismissable.
//	- Layout: listens for the display scaler's RESIZE event and re-anchors
//	  every element. The scaler doesn't know the GUI exists.
//-----------------------------------------------------------------------------

if (instance_number(oGUIManager) > 1) {
	instance_destroy();
	exit;
}

elements_	= [];		// Registered elements, back to front
menus_		= [];		// Open menus, bottom to top
nextOrder_	= 0;

hovered_	= noone;	// Topmost interactive element under the pointer
captured_	= noone;	// Element the left button went down on
focused_	= noone;	// Element receiving keyboard input

mouseX_		= display_mouse_gui_x();
mouseY_		= display_mouse_gui_y();

#region METHODS

/// Adds an element to the top of the draw order and anchors it to the screen
register = function(_element) {
	_element.order_ = nextOrder_++;
	array_push(elements_, _element);
	_element.layout();
}

/// Removes an element (called from its Clean Up)
unregister = function(_element) {
	var _index = array_get_index(elements_, _element);
	if (_index != -1) array_delete(elements_, _index, 1);

	if (hovered_ == _element) hovered_ = noone;
	if (captured_ == _element) captured_ = noone;
	if (focused_ == _element) focused_ = noone;
}

/// Re-anchors every element to the current GUI size
relayout = function() {
	for (var i = 0; i < array_length(elements_); i++) {
		var _element = elements_[i];
		if (instance_exists(_element)) _element.layout();
	}
}

/// Moves an element to the top of the draw order
bring_to_front = function(_element) {
	var _index = array_get_index(elements_, _element);
	if (_index == -1) return;
	array_delete(elements_, _index, 1);
	array_push(elements_, _element);
	_element.order_ = nextOrder_++;
}

/// Moves keyboard focus to _element (or clears it with noone)
set_focus = function(_element) {
	if (_element == focused_) return;

	var _previous = focused_;
	focused_ = _element;
	if (instance_exists(_previous)) _previous.on_focus(false);
	if (instance_exists(_element)) _element.on_focus(true);
}

/// Topmost interactive element under the pointer
find_hovered = function() {
	for (var i = array_length(elements_) - 1; i >= 0; i--) {
		var _element = elements_[i];
		if (!instance_exists(_element) || !_element.can_interact()) continue;
		if (_element.hit_test(mouseX_, mouseY_)) return _element;
	}
	return noone;
}

/// Pushes a menu onto the stack (called from its Create)
push_menu = function(_menu) {
	array_push(menus_, _menu);
	refresh_menus();
}

/// Removes a menu from the stack (called from its Clean Up)
remove_menu = function(_menu) {
	var _index = array_get_index(menus_, _menu);
	if (_index == -1) return;
	array_delete(menus_, _index, 1);
	refresh_menus();
}

/// Menu at the top of the stack, or noone
top_menu = function() {
	var _count = array_length(menus_);
	return _count > 0 ? menus_[_count - 1] : noone;
}

/// Shows menus from the top of the stack down, until one that hides the menus below it
refresh_menus = function() {
	var _show = true;
	for (var i = array_length(menus_) - 1; i >= 0; i--) {
		var _menu = menus_[i];
		if (!instance_exists(_menu)) continue;
		_menu.visible = _show;
		if (_menu.hideBelow) _show = false;
	}
}

#endregion

// HOOK INTO THE DISPLAY SCALER:
//-----------------------------------------------------------------------------
resizeHandle_ = display_scaler_subscribe(DisplayScalerEvent.RESIZE, function(_info) {
	relayout();
});
