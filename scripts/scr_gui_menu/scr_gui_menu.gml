//-----------------------------------------------------------------------------
//	GUI MENUS
//-----------------------------------------------------------------------------
//	Menus are oGUIMenu instances (or children of it) kept on a stack by
//	oGUIManager. A menu owns its elements: hiding the menu hides them and
//	destroying it destroys them, so screens never have to enable and disable
//	their buttons one by one.
//
//		- overlay:    dims the screen and blocks input to everything below
//		- hideBelow:  hides the menus underneath until this one closes
//		- dismissable: Esc, or a click outside the panel, closes the menu
//
//	Build a menu by subclassing oGUIMenu and adding elements in its Create
//	event, or by passing a build function:
//
//		gui_menu_open(oGUIMenu, {
//			title: "Paused", width: 500, height: 400,
//			build: function(_menu) {
//				_menu.add(oGUIButton, 0, 0, { label: "Resume", onClick: gui_menu_close_top });
//			},
//		});
//-----------------------------------------------------------------------------

///
/// @function				gui_menu_open(_menuObject, [_vars])
/// @description            Opens a menu on top of the menu stack. It is centred on the screen
///							unless _vars sets x / y (BASE space) or a different anchor.
///
/// @param {Asset.GMObject}	[_menuObject] - oGUIMenu or a child of it.
/// @param {Struct}			[_vars] - Variable values to apply before the Create event.
/// @returns {Id.Instance}	The new menu.
///
function gui_menu_open(_menuObject, _vars = {}) {
	gui_manager();
	var _x = _vars[$ "x"] ?? BASE_WIDTH / 2;
	var _y = _vars[$ "y"] ?? BASE_HEIGHT / 2;
	return gui_create(_menuObject, _x, _y, _vars);
}

///
/// @function				gui_menu_close(_menu)
/// @description            Closes (destroys) a menu and its elements. Menus that were hidden
///							underneath it are shown again.
///
/// @param {Id.Instance}	[_menu] - The menu to close.
/// @returns {undefined}
///
function gui_menu_close(_menu) {
	if (instance_exists(_menu)) {
		instance_destroy(_menu);
	}
}

///
/// @function				gui_menu_close_top()
/// @description            Closes the menu at the top of the stack, if there is one.
///
/// @returns {undefined}
///
function gui_menu_close_top() {
	gui_menu_close(gui_menu_top());
}

///
/// @function				gui_menu_top()
/// @description            Returns the menu at the top of the stack, or noone.
///
/// @returns {Id.Instance}
///
function gui_menu_top() {
	return instance_exists(oGUIManager) ? oGUIManager.top_menu() : noone;
}

///
/// @function				gui_menu_count()
/// @description            Returns how many menus are open.
///
/// @returns {Real}
///
function gui_menu_count() {
	return instance_exists(oGUIManager) ? array_length(oGUIManager.menus_) : 0;
}
