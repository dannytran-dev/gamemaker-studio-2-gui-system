//-----------------------------------------------------------------------------
//	GUI SYSTEM CONFIG
//-----------------------------------------------------------------------------
//	Elements are authored in BASE_WIDTH x BASE_HEIGHT space (see
//	scr_display_scaler_config) and re-anchored to the screen edges by the
//	display scaler, so one layout works on every aspect ratio.
//-----------------------------------------------------------------------------

// Depth of oGUIManager. Draw GUI runs from the highest depth to the lowest, so a
// very low depth draws the GUI over any other Draw GUI event in the room
#macro GUI_DEPTH -10000

// Keyboard repeat for text input: frames before a held key repeats, then frames between repeats
#macro GUI_KEY_REPEAT_DELAY 24
#macro GUI_KEY_REPEAT_RATE 3

// Two presses closer together than this (in milliseconds) count as a double click
#macro GUI_DOUBLE_CLICK_MS 350

// Frames the text cursor stays on (and off) while blinking
#macro GUI_CURSOR_BLINK_FRAMES 30

// Characters that end a word, for Ctrl+Arrow jumps and double-click selection
#macro GUI_WORD_SEPARATORS " \t.,:;<>?!/\\@#$%^&*()[]{}-=+|\"'`~"

// Command keys, used in place of Ctrl for shortcuts on macOS
#macro GUI_VK_LCOMMAND 91
#macro GUI_VK_RCOMMAND 92

///
/// @function				gui_theme()
/// @description            Colours, font and shape shared by every element. Edit the values
///							here, or change them at runtime (gui_theme().accent = c_orange):
///							elements read the theme every time they draw.
///
/// @returns {Struct}
///
function gui_theme() {
	static _theme = {
		font:			fntDefault,
		textScale:		1,
		radius:			14,		// Corner radius of boxes, in GUI units

		text:			c_white,
		textMuted:		make_colour_rgb(150, 160, 175),
		accent:			make_colour_rgb(63, 169, 245),
		accentText:		make_colour_rgb(10, 20, 32),

		panel:			make_colour_rgb(24, 30, 40),
		panelHover:		make_colour_rgb(36, 45, 60),
		border:			make_colour_rgb(52, 62, 80),
		field:			make_colour_rgb(14, 18, 26),
		selection:		make_colour_rgb(40, 96, 140),

		overlay:		c_black,
		overlayAlpha:	0.6,
		disabledAlpha:	0.35,
	};
	return _theme;
}
