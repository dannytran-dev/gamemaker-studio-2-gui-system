/// @description Init
//-----------------------------------------------------------------------------
//	GUI INPUT FIELD
//	Single-line text input with the editing behaviour people expect:
//		- click to place the caret, drag or Shift+Arrows to select,
//		  double-click to select a word
//		- Home / End, Ctrl+Left / Right word jumps, Backspace / Delete
//		  (Ctrl deletes a word), held keys repeat
//		- Ctrl+A / C / X / V (Cmd on macOS)
//		- Enter calls onSubmit, Esc (or clicking elsewhere) drops focus
//	Text that is wider than the field scrolls to keep the caret in view, and
//	is clipped to the field through a surface.
//
//	Variable Definitions:
//		text		Current text
//		placeholder	Shown while the field is empty and not focused
//		maxLength	Character limit; 0 is unlimited
//		onChange	function(text, field) called when the text changes
//		onSubmit	function(text, field) called when Enter is pressed
//-----------------------------------------------------------------------------

event_inherited();

interactive_	= true;
focusable_		= true;

padding_		= 18;		// Space between the border and the text
caret_			= string_length(text);	// Caret position (0 = before the first character)
anchorPos_		= caret_;	// Other end of the selection; equal to caret_ when nothing is selected
scroll_			= 0;		// How far the text is scrolled left, in GUI units
blink_			= 0;		// Caret blink timer
keyHold_		= {};		// Frames each repeatable key has been held
lastPressTime_	= -1000;	// For double-click detection
dragSelect_		= false;	// Dragging extends the selection (off after a double click)
clip_			= -1;		// Clipping surface

#region METHODS

set_text = function(_text, _notify = true) {
	text = gui_text_sanitize(string(_text));
	if (maxLength > 0) text = string_copy(text, 1, maxLength);
	caret_ = string_length(text);
	anchorPos_ = caret_;
	if (_notify) changed();
}

changed = function() {
	if (!is_undefined(onChange)) onChange(text, id);
}

measure = function(_string) {
	draw_set_font(gui_theme().font);
	return string_width(_string) * gui_theme().textScale;
}

/// Width of the text before caret position _pos
pos_to_x = function(_pos) {
	return measure(string_copy(text, 1, _pos));
}

/// Nearest caret position to a GUI x coordinate
x_to_pos = function(_x) {
	var _local = _x - (x - width / 2 + padding_) + scroll_;
	var _len = string_length(text);
	var _prev = 0;
	for (var i = 1; i <= _len; i++) {
		var _w = pos_to_x(i);
		if (_local < (_prev + _w) / 2) return i - 1;
		_prev = _w;
	}
	return _len;
}

has_selection = function() {
	return caret_ != anchorPos_;
}

get_selection_start = function() {
	return min(caret_, anchorPos_);
}

get_selection_end = function() {
	return max(caret_, anchorPos_);
}

get_selected_text = function() {
	return string_copy(text, get_selection_start() + 1, get_selection_end() - get_selection_start());
}

/// Moves the caret; with _extend the selection anchor stays where it is
move_caret = function(_pos, _extend = false) {
	caret_ = clamp(_pos, 0, string_length(text));
	if (!_extend) anchorPos_ = caret_;
	blink_ = 0;
}

select_all = function() {
	anchorPos_ = 0;
	caret_ = string_length(text);
}

delete_selection = function() {
	if (!has_selection()) return false;
	var _start = get_selection_start();
	text = string_delete(text, _start + 1, get_selection_end() - _start);
	move_caret(_start);
	return true;
}

/// Replaces the selection with _string (typing and pasting)
insert = function(_string) {
	_string = gui_text_sanitize(_string);
	var _deleted = delete_selection();

	if (maxLength > 0) _string = string_copy(_string, 1, max(0, maxLength - string_length(text)));
	if (_string != "") {
		text = string_insert(_string, text, caret_ + 1);
		move_caret(caret_ + string_length(_string));
	}
	if (_deleted || _string != "") changed();
}

/// Backspace (_direction -1) or Delete (_direction 1); _word removes a whole word
erase = function(_direction, _word) {
	if (!has_selection()) {
		var _to;
		if (_direction < 0) _to = _word ? gui_text_word_left(text, caret_) : caret_ - 1;
		else _to = _word ? gui_text_word_right(text, caret_) : caret_ + 1;
		anchorPos_ = clamp(_to, 0, string_length(text));
	}
	if (delete_selection()) changed();
}

/// True on the frame a key goes down, then repeatedly while it's held
key_repeat = function(_key) {
	var _name = string(_key);
	if (keyboard_check_pressed(_key)) {
		keyHold_[$ _name] = 0;
		return true;
	}
	if (!keyboard_check(_key)) return false;

	var _held = (keyHold_[$ _name] ?? 0) + 1;
	keyHold_[$ _name] = _held;
	return _held >= GUI_KEY_REPEAT_DELAY && (_held - GUI_KEY_REPEAT_DELAY) mod GUI_KEY_REPEAT_RATE == 0;
}

/// Scrolls so the caret stays inside the field
keep_caret_visible = function() {
	var _inner = width - padding_ * 2;
	var _caretX = pos_to_x(caret_);
	if (_caretX - scroll_ > _inner) scroll_ = _caretX - _inner;
	if (_caretX - scroll_ < 0) scroll_ = _caretX;
	scroll_ = clamp(scroll_, 0, max(0, measure(text) - _inner));
}

on_focus = function(_isFocused) {
	keyboard_string = "";
	blink_ = 0;
	if (_isFocused) {
		// Native mobile builds get the on-screen keyboard
		if (os_type == os_android || os_type == os_ios) keyboard_virtual_show(kbv_type_default, kbv_returnkey_done, kbv_autocapitalize_none, false);
	}
	else {
		anchorPos_ = caret_;
		if (os_type == os_android || os_type == os_ios) keyboard_virtual_hide();
	}
}

on_press = function(_x, _y) {
	var _pos = x_to_pos(_x);
	var _now = current_time;

	if (_now - lastPressTime_ < GUI_DOUBLE_CLICK_MS) {
		var _bounds = gui_text_word_bounds(text, _pos);
		anchorPos_ = _bounds[0];
		caret_ = _bounds[1];
		lastPressTime_ = -1000;		// A third click starts over
		dragSelect_ = false;
	}
	else {
		move_caret(_pos, keyboard_check(vk_shift));
		lastPressTime_ = _now;
		dragSelect_ = true;
	}
	blink_ = 0;
}

on_drag = function(_x, _y) {
	if (dragSelect_) move_caret(x_to_pos(_x), true);
}

draw_element = function() {
	var _theme = gui_theme();
	var _alpha = get_alpha();
	var _focused = is_focused();
	var _x1 = x - width / 2;
	var _y1 = y - height / 2;

	var _fill = (hovered_ && !_focused) ? merge_colour(_theme.field, _theme.panelHover, 0.5) : _theme.field;
	gui_draw_box(_x1, _y1, _x1 + width, _y1 + height, _fill, _focused ? _theme.accent : _theme.border, _alpha);

	// TEXT, CLIPPED:
	//-------------------------------------------------------------------------
	// The surface is made at screen resolution (_k pixels per GUI unit) so text
	// stays as sharp as the rest of the GUI on HiDPI screens
	var _k = max(1, window_get_width() / display_get_gui_width());
	var _innerX = _x1 + padding_;
	var _innerY = _y1 + 3;
	var _innerW = width - padding_ * 2;
	var _innerH = height - 6;
	var _sw = max(1, ceil(_innerW * _k));
	var _sh = max(1, ceil(_innerH * _k));

	if (surface_exists(clip_) && (surface_get_width(clip_) != _sw || surface_get_height(clip_) != _sh)) {
		surface_free(clip_);
	}
	if (!surface_exists(clip_)) clip_ = surface_create(_sw, _sh);

	surface_set_target(clip_);
	draw_clear(_fill);	// Opaque, so text edges blend exactly as they do on the GUI layer

	var _scale = _theme.textScale * _k;
	var _midY = _sh / 2;
	var _textX = -scroll_ * _k;
	draw_set_font(_theme.font);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	var _lineH = string_height("A") * _scale * 0.8;

	if (text == "" && !_focused) {
		draw_set_colour(_theme.textMuted);
		draw_text_transformed(0, _midY, placeholder, _scale, _scale, 0);
	}
	else {
		if (_focused && has_selection()) {
			draw_set_colour(_theme.selection);
			draw_rectangle(_textX + pos_to_x(get_selection_start()) * _k, _midY - _lineH / 2,
						   _textX + pos_to_x(get_selection_end()) * _k, _midY + _lineH / 2, false);
		}

		draw_set_colour(_theme.text);
		draw_text_transformed(_textX, _midY, text, _scale, _scale, 0);

		if (_focused && (blink_ div GUI_CURSOR_BLINK_FRAMES) mod 2 == 0) {
			var _caretX = _textX + pos_to_x(caret_) * _k;
			draw_set_colour(_theme.accent);
			draw_line_width(_caretX, _midY - _lineH / 2, _caretX, _midY + _lineH / 2, 2 * _k);
		}
	}

	surface_reset_target();
	draw_surface_ext(clip_, _innerX, _innerY, 1 / _k, 1 / _k, 0, c_white, _alpha);
}

#endregion

// Apply maxLength and strip control characters from the starting text
set_text(text, false);
