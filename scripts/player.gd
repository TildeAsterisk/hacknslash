extends CharacterBody3D

@onready var camera_mount: Node3D = $camera_mount
@onready var animation_player: AnimationPlayer = $graphics/char_model/AnimationPlayer
const anim_path = "PlayerAnimationLibrary/"
@onready var graphics: Node3D = $graphics
@onready var game_manager: Node = $"../GameManager"
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var Player_Stats: Dictionary = {}


var current_health: int = 100
@onready var attack_radius: Area3D = $attack_radius
@export var attack_arc_threshold: float = 0.707 #90° arc  # 0.0 = 180° arc (front half)
const JUMP_VELOCITY = 4.5
@export var sensitivity_x = 0.25
@export var sensitivity_y = 0.25
@export var enemy_spawn_time = 5 # TODO: move this to game manmager

var running = false
var is_locked = false
var enemies_hit_this_swing = []


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Initialize stat resources
	Player_Stats["HEALTH"] = Stat.new()
	Player_Stats["HEALTH"].base_value = 100

	Player_Stats["ATK_DAMAGE"] = Stat.new()
	Player_Stats["ATK_DAMAGE"].base_value = 15

	Player_Stats["MOV_SPEED"] = Stat.new()
	Player_Stats["MOV_SPEED"].base_value = 3

	Player_Stats["ATK_SPEED"] = Stat.new()
	Player_Stats["ATK_SPEED"].base_value = 1


func add_player_stat_modifier(stat_name: String, amount: float) -> void:
	match stat_name:
		"ATK_DAMAGE":
			Player_Stats["ATK_DAMAGE"].add_modifier(amount)
		"MOV_SPEED":
			Player_Stats["MOV_SPEED"].add_modifier(amount)
		"ATK_SPEED":
			Player_Stats["ATK_SPEED"].add_modifier(amount)
		"HEALTH":
			Player_Stats["HEALTH"].add_modifier(amount)
		_:
			push_error("Unknown player stat: %s" % stat_name)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x) * sensitivity_x)
		graphics.rotate_y(deg_to_rad(event.relative.x)*sensitivity_x)
		camera_mount.rotate_x(deg_to_rad(-event.relative.y)*sensitivity_y)

func _physics_process(delta):
	var current_mov_speed = Player_Stats["MOV_SPEED"].value

	if !animation_player.is_playing():
		is_locked = false
		enemies_hit_this_swing.clear()  # Clear hit list when attack animation ends
	
	if Input.is_action_just_pressed("Attack"):
		if animation_player.current_animation != anim_path+"punch":
			animation_player.play(anim_path+"punch")
			is_locked = true
			enemies_hit_this_swing.clear()  # Reset hit list for new attack
			_process_attack()  # Perform attack check
	
	if Input.is_action_pressed("Run"):
		current_mov_speed = Player_Stats["MOV_SPEED"].value * 1.5
		running = true
	else:
		current_mov_speed = Player_Stats["MOV_SPEED"].value
		running = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !is_locked:
			if running:
				if animation_player.current_animation != anim_path+"running":
					animation_player.play(anim_path+"running")
			else:
				if animation_player.current_animation != anim_path+"walking":
					animation_player.play(anim_path+"walking")
					
			graphics.look_at(position+direction)
			
		velocity.x = direction.x * current_mov_speed
		velocity.z = direction.z * current_mov_speed
	else:
		if !is_locked:
			if animation_player.current_animation != anim_path+"walking" or animation_player.current_animation != anim_path+"running":
				animation_player.play(anim_path+"idle")
				
		velocity.x = move_toward(velocity.x, 0, current_mov_speed)
		velocity.z = move_toward(velocity.z, 0, current_mov_speed)
		
	if !is_locked:
		move_and_slide()

func _process_attack():
	var current_attack_damage = Player_Stats["ATK_DAMAGE"].value
	# Get player's forward direction (normalized)
	var player_forward = -graphics.global_transform.basis.z.normalized()
	
	# Get all enemies in attack radius
	var bodies = attack_radius.get_overlapping_bodies()
	for body in bodies:
		# Skip if already hit in this swing
		if body in enemies_hit_this_swing:
			continue
		
		# Only process enemies
		if not body.is_in_group("enemy"):
			continue
		
		# Calculate direction to enemy
		var direction_to_enemy = (body.global_transform.origin - global_transform.origin).normalized()
		
		# Calculate dot product (player_forward · direction_to_enemy)
		var dot_product = player_forward.dot(direction_to_enemy)
		
		# Check if enemy is in front (180° arc, dot > 0)
		if dot_product > attack_arc_threshold:
			# Enemy is hit! take damage
			enemies_hit_this_swing.append(body)
			if body.has_method("take_damage"):
				body.take_damage(current_attack_damage)
			else:
				print(body.name+" takes "+current_attack_damage+" damage.")
			# Spawn hit effect
			
			# Add & Update Points!
			game_manager.update_points()

func take_damage(): #dmg: int):
	# health -= dmg
	# if health <= 0:
	# 	get_tree().reload_current_scene()  # Restart on death
	# Update health bar
	var healthbar = game_manager.get_node("CanvasLayer/Control/Healthbar")
	healthbar.value = float(current_health) / Player_Stats["HEALTH"].value * 100
