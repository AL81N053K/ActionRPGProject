extends KinematicBody2D

const ACCELERATION = 300
export var DEFAULT_SPEED = 50
const FRICTION = 2000

enum {
	IDLE,
	WANDER,
	CHASE,
	SEARCH
}

onready var stats = $Stats
onready var sprite = $Sprite
onready var playerDetection = $PlayerDetection
onready var hurtBox = $HurtBox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer
onready var visibilityNotifier = $VisibilityNotifier2D

onready var navigation_agent = $NavigationAgent2D
onready var _timer = $Timer
onready var navigation: Navigation2D = null

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var move_direction = Vector2.ZERO
var _target = Vector2.ZERO
var state = CHASE
var knockback_base: int = 0
var slowness = 1.0
var did_arrive = false
var lose_interest = 0
var max_lose_interest = 1500

func _ready():
	hide()
	stats.max_health = stats.max_health * stats.level
	stats.health = stats.max_health
	$Sprite.self_modulate = Color(rand_range(0,2.0),rand_range(0,2.0),rand_range(0,2.0))
	PlayerStats.connect("sp_signal",self,"sp_signal")
	visibilityNotifier.connect("screen_entered", self, "show")
	visibilityNotifier.connect("screen_exited",self,"hide")
	
	yield(get_tree(), "idle_frame")
	if get_tree().has_group("navigation"):
		var navigation = get_tree().get_nodes_in_group("navigation")[0]
		navigation_agent.set_navigation(navigation)
	set_target_location(global_position)

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_base * delta)
	knockback = move_and_slide(knockback)
	stats.exp_reward = stats.exp_reward_base * stats.level
	
	match state:
		IDLE: 
#			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
			if wanderController.get_time_left() == 0:
				repick_state()
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				repick_state()
			move(delta)
			if _arrived_at_location():
				state = IDLE
		CHASE:
			var player = playerDetection.player
			if player != null:
				wanderController.target_position = player.global_position
				move(delta)
			else:
				state = WANDER
			lose_interest += 1
			if lose_interest >= max_lose_interest: 
				lose_interest = 0
				state = IDLE
	
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func set_target_location(target:Vector2) -> void:
	did_arrive = false
	_target = target
	navigation_agent.set_target_location(target)

func look_at_direction(direction:Vector2) -> void:
	direction = direction.normalized()
	move_direction = direction

func move(delta):
	move_direction = global_position.direction_to(navigation_agent.get_next_location())
	sprite.flip_h = velocity.x < 0
	velocity = velocity.move_toward((move_direction * DEFAULT_SPEED * slowness) / 2, ACCELERATION * delta)

func _arrived_at_location() -> bool:
	return navigation_agent.is_navigation_finished()

func repick_state():
	state = pick_random_state([IDLE,WANDER])
	wanderController.start_wander_timer(rand_range(10,100))

func seek_player():
	if playerDetection.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func sp_signal(type):
	match type:
		"slow_motion":
			slowness = 0.5
			$Sprite.speed_scale = 0.5
		_, "none":
			slowness = 1
			$Sprite.speed_scale = 1

func _on_HurtBox_area_entered(area):
	randomize()
	var random = randi()%10+3
	stats.health -= area.damage
	knockback = area.knockback_vector * (knockback_base * 0.75)
	PlayerStats.set_sp(PlayerStats.sp + random)
	hurtBox.create_hit_effect()
	hurtBox.start_invincibility(0)

func _on_Stats_no_health():
	queue_free()
	PlayerStats.experience += stats.exp_reward

func _on_HurtBox_invincibility_ended():
	animationPlayer.play("Stop")

func _on_HurtBox_invincibility_started():
	animationPlayer.play("Flash")

func _on_HitBox_area_entered(area):
	stats.health -= $HitBox.damage
