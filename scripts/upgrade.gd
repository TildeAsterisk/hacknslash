extends Resource
class_name Upgrade

@export var upgrade_name: String
@export var description: String

# Dictionary to store the randomized modifiers (e.g., {"attack": 5.0, "speed": 1.2})
var modifiers: Dictionary = {}

# Define possible stats and their random ranges
const STAT_CONFIG = {
	"max_health": {"min": 10, "max": 50, "is_int": true},
	"attack_damage": {"min": 5, "max": 15, "is_int": true},
	"walking_speed": {"min": 0.5, "max": 1.5, "is_int": false},
	"attack_speed": {"min": 0.5, "max": 1.5, "is_int": false}
}

## Randomizes 1-3 modifiers from the STAT_CONFIG
func randomize_upgrade():
	modifiers.clear()
	var stat_keys = STAT_CONFIG.keys()
	stat_keys.shuffle() # Randomise the order of stats
	
	# Pick a random number of modifiers to apply (e.g., 1 to 3)
	var count = randi_range(1, stat_keys.size())
	for i in range(count):
		var stat_name = stat_keys[i]
		var config = STAT_CONFIG[stat_name]
		
		var value
		if config["is_int"]:
			value = randi_range(config["min"], config["max"])
		else:
			value = randf_range(config["min"], config["max"])
		
		modifiers[stat_name] = value
	
	# Update name and description dynamically
	upgrade_name = "Random upgrade"
	description = "Increases: " + str(modifiers)
