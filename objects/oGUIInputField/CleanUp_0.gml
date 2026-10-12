/// @description Free Surface

event_inherited();

if (surface_exists(clip_)) {
	surface_free(clip_);
}
