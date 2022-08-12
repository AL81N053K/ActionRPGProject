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

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var state = CHASE
var knockback_base: int = 0
var slowness = 1.0

func _ready():
	hide()
	stats.max_health = stats.max_health * stats.level
	stats.health = stats.max_health
	$Sprite.self_modulate = Color(rand_range(0,2.0),rand_range(0,2.0),rand_range(0,2.0))
	PlayerStats.connect("sp_signal",self,"sp_signal")
	visibilityNotifier.connect("screen_entered", self, "show")
	visibilityNotifier.connect("screen_exited",self,"hide")

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
			
			accelerate_towards_point(wanderController.target_position, delta)
			
			if global_position.distance_to(wanderController.target_position) <= 4:
				repick_state()
			
		CHASE:
			var player = playerDetection.player
			if player != null:
				wanderController.target_position = player.global_position
				accelerate_towards_point(wanderController.target_position, delta)
			else:
				state = WANDER
			sprite.flip_h = velocity.x < 0
	
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * DEFAULT_SPEED * slowness, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

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
