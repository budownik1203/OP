extends OmniLight3D
## Migotanie ognia w koszu.

var _t := randf() * 10.0
var _baza := 1.3


func _process(dt: float) -> void:
	_t += dt
	light_energy = _baza * (0.85 + 0.1 * sin(_t * 9.0) + 0.08 * sin(_t * 23.0 + 1.0) + 0.05 * sin(_t * 41.0))
