extends Node3D

const max_world_enemy_count : int = 15
var spawned_entities : Array = []
var points : int = 0
@onready var label: Label = $CanvasLayer/Control/Label
@onready var upgrade_panel: Control = $CanvasLayer/UpgradePanel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setup spawn timer
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = enemy_spawn_time
	timer.timeout.connect(spawn_enemy_around_player)
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


#~~/ Spawn Enemies \~~#
@export var enemy_scene: PackedScene # Drag your enemy.tscn here in the Inspector
@onready var player: CharacterBody3D = $"../Player"
@export var min_spawn_distance: float = 10.0
@export var max_spawn_distance: float = 20.0
@export var enemy_spawn_time: int = 5
var group_spawn_size: int = 10
func spawn_enemy_around_player():
	if spawned_entities.size() > max_world_enemy_count:
		return
	for e in group_spawn_size:
		# 1. Pick a random angle (0 to 360 degrees in radians)
		var angle = randf_range(0, TAU) 
		
		# 2. Pick a random distance within your range
		# Use sqrt for more uniform distribution if spawning in a full circle
		var distance = randf_range(min_spawn_distance, max_spawn_distance)
		# 3. Calculate the relative position offset
		var offset = Vector3(cos(angle) * distance, 30, sin(angle) * distance)
		
		# 4. Create and place the enemy
		var enemy = enemy_scene.instantiate()
		spawned_entities.push_back(enemy)
		get_parent().add_child(enemy) # Add to the world, not as a child of the spawner
		enemy.add_to_group("enemy")
		#
		var enemy_pos = player.global_position + offset
		# Get Y heght, terraint surface
		var ground_y = get_terrain_height(enemy_pos)
		enemy.global_position = Vector3(enemy_pos.x, ground_y, enemy_pos.z)
		# Spawn enemies in random order around player.
		
	return

func update_points():
	points+=1
	label.text = str(points)
	if points % 10 == 0:
		get_tree().paused = true
		show_upgrade_panel()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func get_terrain_height(pos: Vector3) -> float:
	# Use a RayCast to find the exact floor height at these coordinates
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(pos, pos + Vector3.DOWN * 200)
	var result = space_state.intersect_ray(query)
	
	if result:
		return result.position.y
	return 0.0 # Default if no ground hit

func show_upgrade_panel():
	var up1 = Upgrade.new()
	up1.randomize_upgrade()
	var up2 = Upgrade.new()
	up2.randomize_upgrade()
	var up3 = Upgrade.new()
	up3.randomize_upgrade()
	upgrade_panel.show_upgrades([up1, up2, up3])
