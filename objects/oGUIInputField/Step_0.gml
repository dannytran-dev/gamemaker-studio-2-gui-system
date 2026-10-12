/// @description Keyboard

if (!is_focused()) {
	scroll_ = 0;
	exit;
}

blink_++;

var _shift = keyboard_check(vk_shift);
var _ctrl = (os_type == os_macosx)
	? (keyboard_check(GUI_VK_LCOMMAND) || keyboard_check(GUI_VK_RCOMMAND))
	: keyboard_check(vk_control);

// TYPING:
//-----------------------------------------------------------------------------
// keyboard_string collects typed characters (including from on-screen
// keyboards). Shortcuts can leave letters in it, so it's ignored while Ctrl is held.
if (keyboard_string != "") {
	if (!_ctrl) insert(keyboard_string);
	keyboard_string = "";
}

// SHORTCUTS:
//-----------------------------------------------------------------------------
if (_ctrl) {
	if (keyboard_check_pressed(ord("A"))) {
		select_all();
	}
	if (keyboard_check_pressed(ord("C")) && has_selection()) {
		clipboard_set_text(get_selected_text());
	}
	if (keyboard_check_pressed(ord("X")) && has_selection()) {
		clipboard_set_text(get_selected_text());
		if (delete_selection()) changed();
	}
	if (keyboard_check_pressed(ord("V")) && clipboard_has_text()) {
		insert(clipboard_get_text());
	}
}

// NAVIGATION AND DELETING:
//-----------------------------------------------------------------------------
if (key_repeat(vk_left)) {
	if (has_selection() && !_shift && !_ctrl) move_caret(get_selection_start());
	else move_caret(_ctrl ? gui_text_word_left(text, caret_) : caret_ - 1, _shift);
}
if (key_repeat(vk_right)) {
	if (has_selection() && !_shift && !_ctrl) move_caret(get_selection_end());
	else move_caret(_ctrl ? gui_text_word_right(text, caret_) : caret_ + 1, _shift);
}
if (keyboard_check_pressed(vk_home))	move_caret(0, _shift);
if (keyboard_check_pressed(vk_end))		move_caret(string_length(text), _shift);
if (key_repeat(vk_backspace))			erase(-1, _ctrl);
if (key_repeat(vk_delete))				erase(1, _ctrl);

if (keyboard_check_pressed(vk_enter) && !is_undefined(onSubmit)) {
	onSubmit(text, id);
}

keep_caret_visible();
