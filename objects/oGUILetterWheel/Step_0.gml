/// @description Mouse Wheel

if (hovered_) {
	if (mouse_wheel_up())	spin(1);
	if (mouse_wheel_down())	spin(-1);
}
