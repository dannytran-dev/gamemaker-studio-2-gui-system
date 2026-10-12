/// @description Destroy Elements

for (var i = 0; i < array_length(elements_); i++) {
	if (instance_exists(elements_[i])) {
		instance_destroy(elements_[i]);
	}
}
