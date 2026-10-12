/// @description Init
//-----------------------------------------------------------------------------
//	GUI SLIDER
//	Drag the knob, or click anywhere on the track to jump to that value.
//	Dragging keeps working when the pointer leaves the slider, which matters
//	on touch screens.
//
//	Variable Definitions:
//		value		Current value
//		minValue	Value at the left end
//		maxValue	Value at the right end
//		step		Snap increment; 0 is continuous
//		decimals	Decimal places shown next to the label
//		label		Text above the track; empty hides it and the value
//		onChange	function(value, slider) called while the value changes
//-----------------------------------------------------------------------------

event_inherited();

interactive_ = true;

#region METHODS

/// Sets the value (clamped and snapped); calls onChange if it changed and _notify is true
set_value = function(_value, _notify = true) {
	if (step > 0) _value = minValue + round((_value - minValue) / step) * step;
	_value = clamp(_value, min(minValue, maxValue), max(minValue, maxValue));
	if (_value == value) return;

	value = _value;
	if (_notify && !is_undefined(onChange)) onChange(value, id);
}

/// The track is inset by the knob radius so the knob never leaves the element
get_knob_radius = function() {
	return height * 0.36;
}

get_track_left = function() {
	return x - width / 2 + get_knob_radius();
}

get_track_width = function() {
	return width - get_knob_radius() * 2;
}

/// 0 to 1 position of the current value along the track
get_ratio = function() {
	if (maxValue == minValue) return 0;
	return clamp((value - minValue) / (maxValue - minValue), 0, 1);
}

set_from_pointer = function(_x) {
	var _ratio = clamp((_x - get_track_left()) / get_track_width(), 0, 1);
	set_value(lerp(minValue, maxValue, _ratio));
}

on_press = function(_x, _y) {
	set_from_pointer(_x);
}

on_drag = function(_x, _y) {
	set_from_pointer(_x);
}

draw_element = function() {
	var _theme = gui_theme();
	var _alpha = get_alpha();
	var _left = get_track_left();
	var _knobX = _left + get_track_width() * get_ratio();
	var _trackH = max(6, height * 0.16);
	var _active = hovered_ || pressed_;

	// Label and value
	if (label != "") {
		var _labelY = y - height / 2 - 6;
		gui_draw_label(x - width / 2, _labelY, label, _theme.textMuted, _alpha, fa_left, fa_bottom, _theme.textScale * 0.8);
		gui_draw_label(x + width / 2, _labelY, string_format(value, 0, decimals), _theme.text, _alpha, fa_right, fa_bottom, _theme.textScale * 0.8);
	}

	// Track, then the filled part up to the knob
	var _r = _trackH;
	gui_draw_box(_left, y - _trackH / 2, _left + get_track_width(), y + _trackH / 2, _theme.border, _theme.border, _alpha, _r / 2);
	if (_knobX > _left) {
		gui_draw_box(_left, y - _trackH / 2, _knobX, y + _trackH / 2, _theme.accent, _theme.accent, _alpha, _r / 2);
	}

	// Knob
	var _knobR = get_knob_radius() * (_active ? 1 : 0.85);
	draw_set_alpha(_alpha);
	draw_set_circle_precision(32);
	draw_set_colour(_theme.accent);
	draw_circle(_knobX, y, _knobR, false);
	draw_set_colour(_theme.text);
	draw_circle(_knobX, y, _knobR * 0.55, false);
	draw_set_alpha(1);
}

#endregion

// Snap and clamp the starting value without reporting it as a change
var _start = value;
value = undefined;
set_value(_start, false);
