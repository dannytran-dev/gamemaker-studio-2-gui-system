//-----------------------------------------------------------------------------
//	GUI TEXT HELPERS
//	Positions are caret positions: 0 is before the first character and
//	string_length(_text) is after the last one.
//-----------------------------------------------------------------------------

///
/// @function				gui_text_is_word_char(_char)
/// @description            True if the character is part of a word. string_letters() only
///							knows A-Z, so this checks against a list of separators instead.
///
/// @param {String}			[_char] - A single character.
/// @returns {Bool}
///
function gui_text_is_word_char(_char) {
	return _char != "" && string_pos(_char, GUI_WORD_SEPARATORS) == 0;
}

///
/// @function				gui_text_word_left(_text, _pos)
/// @description            Caret position at the start of the word before _pos (Ctrl+Left).
///
/// @param {String}			[_text] - The text.
/// @param {Real}			[_pos] - The caret position to start from.
/// @returns {Real}
///
function gui_text_word_left(_text, _pos) {
	while (_pos > 0 && !gui_text_is_word_char(string_char_at(_text, _pos))) _pos--;
	while (_pos > 0 && gui_text_is_word_char(string_char_at(_text, _pos))) _pos--;
	return _pos;
}

///
/// @function				gui_text_word_right(_text, _pos)
/// @description            Caret position at the end of the word after _pos (Ctrl+Right).
///
/// @param {String}			[_text] - The text.
/// @param {Real}			[_pos] - The caret position to start from.
/// @returns {Real}
///
function gui_text_word_right(_text, _pos) {
	var _len = string_length(_text);
	while (_pos < _len && !gui_text_is_word_char(string_char_at(_text, _pos + 1))) _pos++;
	while (_pos < _len && gui_text_is_word_char(string_char_at(_text, _pos + 1))) _pos++;
	return _pos;
}

///
/// @function				gui_text_word_bounds(_text, _pos)
/// @description            Start and end caret positions of the word around _pos (double click).
///
/// @param {String}			[_text] - The text.
/// @param {Real}			[_pos] - A caret position inside or next to the word.
/// @returns {Array<Real>}	[start, end]
///
function gui_text_word_bounds(_text, _pos) {
	var _len = string_length(_text);
	var _start = _pos;
	var _end = _pos;
	while (_start > 0 && gui_text_is_word_char(string_char_at(_text, _start))) _start--;
	while (_end < _len && gui_text_is_word_char(string_char_at(_text, _end + 1))) _end++;
	return [_start, _end];
}

///
/// @function				gui_text_sanitize(_text)
/// @description            Strips line breaks and other control characters from typed or
///							pasted text, for single-line input.
///
/// @param {String}			[_text] - The raw text.
/// @returns {String}
///
function gui_text_sanitize(_text) {
	var _out = "";
	var _len = string_length(_text);
	for (var i = 1; i <= _len; i++) {
		var _char = string_char_at(_text, i);
		var _code = ord(_char);
		if (_code >= 32 && _code != 127) _out += _char;
	}
	return _out;
}
