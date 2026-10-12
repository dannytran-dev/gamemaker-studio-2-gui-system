/// @description Route Input
// Begin Step, so every element sees this frame's hover / press state in its own Step

mouseX_ = display_mouse_gui_x();
mouseY_ = display_mouse_gui_y();

// HOVER:
//-----------------------------------------------------------------------------
var _hovered = find_hovered();
if (_hovered != hovered_) {
	if (instance_exists(hovered_)) {
		hovered_.hovered_ = false;
		hovered_.on_hover(false);
	}
	hovered_ = _hovered;
	if (instance_exists(_hovered)) {
		_hovered.hovered_ = true;
		_hovered.on_hover(true);
	}
}

// LEFT BUTTON:
//-----------------------------------------------------------------------------
if (mouse_check_button_pressed(mb_left)) {
	// Clicking anything other than the focused element takes focus away from it
	set_focus((hovered_ != noone && hovered_.focusable_) ? hovered_ : noone);

	captured_ = hovered_;
	if (instance_exists(captured_)) {
		captured_.pressed_ = true;
		captured_.on_press(mouseX_, mouseY_);
	}
}
else if (mouse_check_button(mb_left) && instance_exists(captured_)) {
	captured_.on_drag(mouseX_, mouseY_);
}

if (mouse_check_button_released(mb_left)) {
	// A release only counts as a click if it happens over the element that was pressed
	if (instance_exists(captured_)) {
		captured_.pressed_ = false;
		captured_.on_release(mouseX_, mouseY_, captured_ == find_hovered());
	}
	captured_ = noone;
}

// ESCAPE:
//-----------------------------------------------------------------------------
if (keyboard_check_pressed(vk_escape)) {
	if (focused_ != noone) {
		set_focus(noone);
	}
	else {
		var _top = top_menu();
		if (instance_exists(_top) && _top.dismissable) _top.close();
	}
}
