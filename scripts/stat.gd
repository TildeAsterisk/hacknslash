extends Resource
class_name Stat

signal value_changed

@export var base_value: float = 1
var _modifiers: Array[float] = [] # Flat bonuses
var _multipliers: Array[float] = [] # Percentage bonuses (e.g., 0.2 for 20%)

var value: float:
	get:
		return _calculate_final_value()

func _calculate_final_value() -> float:
	var total = base_value
	# Add flats first
	for mod in _modifiers:
		total += mod
	# Then apply multipliers
	var mult_sum = 1.0
	for mult in _multipliers:
		mult_sum += mult
	return total * mult_sum

func add_modifier(amount: float, is_multiplier: bool = false):
	if is_multiplier:
		_multipliers.append(amount)
	else:
		_modifiers.append(amount)
	value_changed.emit()

# Add a clear_modifiers() function here for when buffs expire!
