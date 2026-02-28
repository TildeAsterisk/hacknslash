extends CharacterBody3D
@onready var player: CharacterBody3D = $"../Player"
@onready var animation_player: AnimationPlayer = $graphics/char_model/AnimationPlayer
@onready var graphics: Node3D = $graphics

const anim_path = "EnemyAnimationLibrary/"

const SPEED = 2.5
const JUMP_VELOCITY = 4.5

enum State { IDLE, CHASE, ATTACK }
var state: State = State.IDLE

var is_dead = false

@export var detection_radius: float = 12.0
@export var attack_range: float = 1.6
@export var attack_cooldown: float = 1.2
var attack_timer: float = 0.0
@export var attack_damage: int = 10

func _physics_process(delta: float) -> void:
	# gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	if not is_instance_valid(player):
		return
		
	# Check if dead
	if is_dead:
		return

	var to_player: Vector3 = player.global_transform.origin - global_transform.origin
	var horizontal = Vector3(to_player.x, 0, to_player.z)
	var dist = horizontal.length()

	# State transitions
	if dist <= attack_range:
		state = State.ATTACK
	elif dist <= detection_radius:
		state = State.CHASE
	else:
		state = State.IDLE

	# State behaviour
	match state:
		State.IDLE:
			if animation_player.current_animation != anim_path+"idle" and animation_player.has_animation(anim_path+"idle"):
				animation_player.play(anim_path+"idle")
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		State.CHASE:
			if horizontal.length() > 0.001:
				var dir = horizontal.normalized()
				# face player (only yaw)
				graphics.look_at(global_transform.origin + Vector3(dir.x, 0, dir.z))
				if animation_player.current_animation != "running" and animation_player.has_animation(anim_path+"running"):
					animation_player.play(anim_path+"running")
				velocity.x = dir.x * SPEED
				velocity.z = dir.z * SPEED

		State.ATTACK:
			# Stop running before attacking
			#animation_player.stop(true)
			# stop moving while attacking
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

			if attack_timer <= 0.0:
				# choose an available attack animation
				var attack_anim := "null"
				for name in ["kick","attack", "Atk", "kick", "hit"]:
					if animation_player.has_animation(anim_path+name):
						attack_anim = name
						break
				if attack_anim:
					animation_player.play(anim_path+attack_anim)
				attack_timer = attack_cooldown

				# apply damage / knockback if very close
				if dist <= attack_range + 0.25:
					if player.has_method("take_damage"):
						player.take_damage(attack_damage)
					else:
						# fallback: nudge player's velocity (if CharacterBody3D)
						if player is CharacterBody3D:
							player.velocity += (horizontal.normalized() * 4.0)

	# cooldown
	attack_timer = max(attack_timer - delta, 0.0)

	# move
	move_and_slide()

func take_damage(dmg: int) -> void:
	is_dead = true
	print(self.name+" has taken "+str(dmg)+ " damage. ouch!")
	# Play death animation
	if animation_player.current_animation != anim_path+"knock_down" and animation_player.has_animation(anim_path+"knock_down"):
		animation_player.play(anim_path+"knock_down")
	# Delete object once current animation is finished
	await animation_player.animation_finished
	queue_free() # Delete object... /!\
