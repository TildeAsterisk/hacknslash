extends Control

@onready var button1: Button = $Panel/HBoxContainer/Button1
@onready var button2: Button = $Panel/HBoxContainer/Button2
@onready var button3: Button = $Panel/HBoxContainer/Button3

var upgrades = []

func _ready():
	button1.set_meta("indx",0)
	button1.pressed.connect(_on_button_pressed.bind(button1))
	button2.set_meta("indx",1)
	button2.pressed.connect(_on_button_pressed.bind(button2))
	button3.set_meta("indx",2)
	button3.pressed.connect(_on_button_pressed.bind(button3))

	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func show_upgrades(upgs: Array):
	upgrades = upgs
	button1.text = upgs[0].description
	button2.text = upgs[1].description
	button3.text = upgs[2].description
	visible = true

func _on_button_pressed(button: Button) -> void:
	var index = int(button.get_meta("indx"))
	apply_upgrade(upgrades[index])
	print("Applied upgrade: " + upgrades[index].upgrade_name + " - " + upgrades[index].description)

	# Resume game
	get_tree().paused = false
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func apply_upgrade(up: Upgrade):
	var game_manager = get_parent().get_parent()  # CanvasLayer -> GameManager
	var player = game_manager.get_parent().get_node("Player")

	for stat_name in up.modifiers.keys():
		var amount = float(up.modifiers[stat_name])
		player.add_player_stat_modifier(stat_name, amount)

	hide()
