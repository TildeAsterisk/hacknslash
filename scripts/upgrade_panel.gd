extends Control

@onready var button1: Button = $Panel/HBoxContainer/Button1
@onready var button2: Button = $Panel/HBoxContainer/Button2
@onready var button3: Button = $Panel/HBoxContainer/Button3

var upgrades = []

func _ready():
	button1.connect("pressed", Callable(self, "_on_button_pressed").bind(0), 0)
	button2.connect("pressed", Callable(self, "_on_button_pressed").bind(1), 1)
	button3.connect("pressed", Callable(self, "_on_button_pressed").bind(2), 2)
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func show_upgrades(upgs: Array):
	upgrades = upgs
	button1.text = upgs[0].description
	button2.text = upgs[1].description
	button3.text = upgs[2].description
	visible = true

func _on_button_pressed(index: int):
	apply_upgrade(upgrades[index])
	print("Applied upgrade: " + upgrades[index].upgrade_name)

	# Resume game
	get_tree().paused = false
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func apply_upgrade(up: Upgrade):
	var game_manager = get_parent().get_parent()  # CanvasLayer -> GameManager
	var player = game_manager.get_parent().get_node("Player")
	for stat in up.modifiers:
		if stat == "attack_damage":
			player.attack_damage += int(up.modifiers[stat])
		elif stat == "walking_speed":
			player.walking_speed += up.modifiers[stat]
		elif stat == "running_speed":
			player.running_speed += up.modifiers[stat]
		elif stat == "max_health":
			player.max_health += int(up.modifiers[stat])
			player.health = min(player.health + int(up.modifiers[stat]), player.max_health)
	hide()
	get_tree().paused = false
