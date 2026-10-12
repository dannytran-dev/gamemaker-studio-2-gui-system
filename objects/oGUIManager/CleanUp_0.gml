/// @description Unhook From Scaler

// A duplicate destroys itself before it subscribes
if (variable_instance_exists(id, "resizeHandle_")) {
	display_scaler_unsubscribe(resizeHandle_);
}
