/// @description Hover Animation

var _target = 1;
if (can_interact()) {
	if (pressed_ && hovered_) _target = 0.96;
	else if (hovered_) _target = 1.04;
}
scale_ = lerp(scale_, _target, 0.35);
