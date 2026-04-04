extends Resource
class_name Upgrade

@export var upgrade_name: String
@export var description: String

# Dictionary to store the randomized modifiers (e.g., {"attack": 5.0, "speed": 1.2})
var modifiers: Dictionary = {}

## Define possible stats and their random ranges for upgrades
const STAT_CONFIG = {
	"HEALTH": {"min": 10, "max": 50, "is_int": true, "symbol":"♥"},
	"ATK_DAMAGE": {"min": 5, "max": 15, "is_int": false, "symbol":"⚔"},
	"MOV_SPEED": {"min": 0.5, "max": 1.5, "is_int": false, "symbol":"👟"},
	"ATK_SPEED": {"min": 0.5, "max": 1.5, "is_int": false, "symbol":"⏩"},
	"JUMP_VEL": {"min": 0.5, "max": 1.5, "is_int": false, "symbol":"⏫"}
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
			value = snappedf(randf_range(config["min"], config["max"]), 0.01)
		
		modifiers[stat_name] = value
	
	# Update name and description dynamically
	upgrade_name = "Random upgrade"
	description = ""
	for key in modifiers:
		description += STAT_CONFIG[key].symbol + " " + str(modifiers[key]) + "\n"
