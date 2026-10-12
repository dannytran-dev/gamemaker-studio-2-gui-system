/// @description Build The Demo
//-----------------------------------------------------------------------------
//	Showcase for the GUI system, running on top of the display scaler:
//		- HUD: one element pinned to each corner of the screen. Resize the
//		  window and they stay put while the menu stays centred.
//		- Menu stack: the main menu opens Settings and Player Name as
//		  overlays (Esc or a click outside closes them) and About, which
//		  hides the main menu until it closes.
//		- World: the camera zoom slider zooms the world behind the GUI;
//		  the GUI keeps its size.
//
//	Callbacks are methods of this instance passed by reference. A function
//	written inline inside a struct literal ({ onClick: function() {...} })
//	is bound to that struct instead, so it couldn't see this instance.
//-----------------------------------------------------------------------------

// EXPAND keeps the whole BASE_WIDTH x BASE_HEIGHT layout on screen at any aspect
// ratio (phones in portrait included); the scaler defaults to LOCK_HEIGHT
display_scaler_set_mode(DisplayScaleMode.EXPAND);

time_		= 0;
clicks_		= 0;
playerName_	= "AAA";
volume_		= 80;

playButton_	= noone;
nameWheels_	= [];
nameInput_	= noone;

colGrid_	= make_colour_rgb(30, 34, 43);
colSafe_	= make_colour_rgb(18, 30, 46);
colAccent_	= make_colour_rgb(63, 169, 245);
colWarm_	= make_colour_rgb(255, 196, 61);

#region CALLBACKS

add_click = function() {
	clicks_++;
	clicksText_.set_text("Clicks: " + string(clicks_));
}

toggle_info = function(_checked) {
	display_scaler_show_overlay(_checked);
}

set_zoom = function(_value) {
	display_scaler_set_zoom(_value);
}

set_volume = function(_value) {
	volume_ = _value;
}

/// Cycles the display scaler's scale mode and shows the new one on the button
cycle_mode = function(_button) {
	var _mode = display_scaler_get_mode();
	display_scaler_set_mode(is_numeric(_mode) ? (_mode + 1) mod DisplayScaleMode.__COUNT : 0);
	_button.set_label(get_mode_label());
}

get_mode_label = function() {
	var _info = display_scaler_get_info();
	return "Scale mode: " + (is_undefined(_info) ? "-" : _info.modeName);
}

disable_play = function(_checked) {
	if (instance_exists(playButton_)) playButton_.enabled = !_checked;
}

/// Saves the typed name, or the letter wheels' initials if nothing was typed
save_name = function() {
	var _name = string_trim(nameInput_.text);
	if (_name == "") {
		for (var i = 0; i < array_length(nameWheels_); i++) _name += nameWheels_[i].get_letter();
	}
	playerName_ = _name;
	playerText_.set_text("Player: " + playerName_);
	nameInput_.get_menu().close();
}

/// Closes the menu a button belongs to. onClick passes the button in, so one
/// method serves every Close / OK button.
close_owner = function(_button) {
	_button.get_menu().close();
}

#endregion

#region MENUS

open_main_menu = function() {
	gui_menu_open(oGUIMenu, { title: "Main Menu", width: 560, height: 540, overlay: false, build: build_main_menu });
}

open_settings = function() {
	gui_menu_open(oGUIMenu, { title: "Settings", width: 680, height: 680, dismissable: true, build: build_settings });
}

open_name_menu = function() {
	gui_menu_open(oGUIMenu, { title: "Player Name", width: 640, height: 640, dismissable: true, build: build_name_menu });
}

open_about = function() {
	gui_menu_open(oGUIMenu, { title: "About", width: 760, height: 560, hideBelow: true, build: build_about });
}

build_main_menu = function(_menu) {
	var _w = 400;
	var _h = 72;
	playButton_ = _menu.add(oGUIButton, 0, -120, { width: _w, height: _h, label: "Play", primary: true, onClick: add_click });
	_menu.add(oGUIButton, 0, -24, { width: _w, height: _h, label: "Player Name", onClick: open_name_menu });
	_menu.add(oGUIButton, 0, 72, { width: _w, height: _h, label: "Settings", onClick: open_settings });
	_menu.add(oGUIButton, 0, 168, { width: _w, height: _h, label: "About", onClick: open_about });
}

build_settings = function(_menu) {
	var _w = 520;
	_menu.add(oGUISlider, 0, -150, {
		width: _w, height: 48, label: "Camera zoom (world only)", decimals: 2, step: 0.05,
		minValue: DISPLAY_SCALER_ZOOM_MIN, maxValue: DISPLAY_SCALER_ZOOM_MAX, value: display_scaler_get_zoom(),
		onChange: set_zoom,
	});
	_menu.add(oGUISlider, 0, -40, {
		width: _w, height: 48, label: "Volume", decimals: 0, minValue: 0, maxValue: 100, step: 1, value: volume_,
		onChange: set_volume,
	});
	_menu.add(oGUIButton, 0, 50, { width: _w, height: 64, label: get_mode_label(), onClick: cycle_mode });
	_menu.add(oGUICheckbox, 0, 140, {
		width: _w, height: 56, label: "Disable the Play button",
		checked: instance_exists(playButton_) && !playButton_.enabled,
		onChange: disable_play,
	});
	_menu.add(oGUIButton, 0, 250, { width: 240, height: 64, label: "Close", primary: true, onClick: close_owner });
}

build_name_menu = function(_menu) {
	// Three letter wheels for arcade-style initials...
	nameWheels_ = [];
	for (var i = 0; i < 3; i++) {
		var _wheel = _menu.add(oGUILetterWheel, (i - 1) * 120, -100, { width: 96, height: 176 });
		_wheel.set_letter(string_char_at(playerName_, i + 1));
		array_push(nameWheels_, _wheel);
	}

	// ...or a typed name, which is used instead when it isn't empty
	nameInput_ = _menu.add(oGUIInputField, 0, 70, {
		width: 480, height: 64, placeholder: "Or type a name...", maxLength: 16, onSubmit: save_name,
	});

	_menu.add(oGUIButton, -125, 210, { width: 230, height: 64, label: "Cancel", onClick: close_owner });
	_menu.add(oGUIButton, 125, 210, { width: 230, height: 64, label: "Save", primary: true, onClick: save_name });
}

build_about = function(_menu) {
	_menu.add(oGUIImage, 0, -120, { sprite: sGUIDemoIcon, width: 96, height: 96 });
	_menu.add(oGUIText, 0, 30, {
		maxWidth: 640, scale: 0.7, colour: gui_theme().textMuted,
		text: "Elements are laid out once at " + string(BASE_WIDTH) + " x " + string(BASE_HEIGHT)
			+ " and pinned to an anchor. When the display scaler resizes the screen, the GUI manager "
			+ "re-anchors them, so one layout fits desktop, ultra-wide and phone screens.\n\n"
			+ "This dialog hides the main menu until it closes.",
	});
	_menu.add(oGUIButton, 0, 210, { width: 240, height: 64, label: "OK", primary: true, onClick: close_owner });
}

#endregion

#region HUD

var _theme = gui_theme();
var _m = 48;	// Margin from the screen edges

gui_create(oGUIText, BASE_WIDTH / 2, _m, {
	anchor: DisplayAnchor.TOPCENTER, text: "GameMaker GUI System", scale: 1.5,
});
gui_create(oGUIText, BASE_WIDTH / 2, _m + 64, {
	anchor: DisplayAnchor.TOPCENTER, text: "Resize the window: every element stays anchored", scale: 0.65, colour: _theme.textMuted,
});

clicksText_ = gui_create(oGUIText, _m, _m, {
	anchor: DisplayAnchor.TOPLEFT, text: "Clicks: 0",
});
playerText_ = gui_create(oGUIText, _m, _m + 48, {
	anchor: DisplayAnchor.TOPLEFT, text: "Player: " + playerName_, scale: 0.8, colour: _theme.textMuted,
});

gui_create(oGUIButton, BASE_WIDTH - _m - 110, _m + 32, {
	anchor: DisplayAnchor.TOPRIGHT, width: 220, height: 64, label: "Settings", onClick: open_settings,
});

gui_create(oGUIText, _m, BASE_HEIGHT - _m, {
	anchor: DisplayAnchor.BOTTOMLEFT, text: "Esc closes the top menu", scale: 0.65, colour: _theme.textMuted,
});

gui_create(oGUICheckbox, BASE_WIDTH - _m - 150, BASE_HEIGHT - _m - 28, {
	anchor: DisplayAnchor.BOTTOMRIGHT, width: 300, height: 56, label: "Display info", onChange: toggle_info,
});

#endregion

open_main_menu();
