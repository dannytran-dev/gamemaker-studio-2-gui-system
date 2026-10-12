/// @description Leave The Menu Stack

event_inherited();

with (oGUIManager) {
	remove_menu(other.id);
}
