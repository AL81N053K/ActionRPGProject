extends KinematicBody2D

const EnemyDefeatEffect = preload("res://Nodes/Instances/EnemyDefeatEffect.tscn")

const ACCELERATION = 300
export var DEFAULT_SPEED = 50
const FRICTION = 200

enum {
	IDLE,
	WANDER,
	CHASE,
	SEARCH
}

var path: Array = []
var levelNavigation: Navigation2D = null
onready var line2D = $Line2D

onready var stats = $Stats
onready var sprite = $Sprite
onready var playerDetection = $PlayerDetection
onready var hurtBox = $HurtBox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer
onready var visibilityNotifier = $VisibilityNotifier2D

var floating_text = preload("res://Nodes/UI/FloatingText.tscn")

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var state = IDLE
var knockback_base: int = 200
var slowness = 1.0
var rotationSpeed = 2.0
var a_tick = 2

func _ready():
	hide()
	stats.max_health = stats.max_health * stats.level
	stats.health = stats.max_health
	$EnemyHPBar/Label.text = str(stats.health, "/", stats.max_health)
	update_health()
# warning-ignore:return_value_discarded
	PlayerStats.connect("sp_signal",self,"sp_signal")
	visibilityNotifier.connect("screen_entered", self, "show")
	visibilityNotifier.connect("screen_exited",self,"hide")
	yield(get_tree(), "idle_frame")
	if get_tree().has_group("Navigation"):
		levelNavigation = get_tree().get_nodes_in_group("Navigation")[0]
	

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_base * delta)
	knockback = move_and_slide(knockback)
	stats.exp_reward = stats.exp_reward_base * stats.level
	
	if stats.health < stats.max_health: $EnemyHPBar.show()
	if stats.health >= stats.max_health: $EnemyHPBar.hide()
	var hp_precent:float = stepify(float(stats.health) / stats.max_health * 1.0,0.01)
	if hp_precent > .66: $EnemyHPBar/Over.tint_progress = Color(0,1,0)
	if hp_precent <= .66 and hp_precent > .33: $EnemyHPBar/Over.tint_progress = Color(.8,.8,.1)
	if hp_precent <= .33: $EnemyHPBar/Over.tint_progress = Color(.8,.05,.1)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				repick_state()
		WANDER:
			seek_player()
			navigate(delta)
			_rotate_to_target(wanderController.target_position, delta)
			if global_position.distance_to(wanderController.target_position) <= 4:
				repick_state()
		CHASE:
			Music.SetGameState("Combat")
			var player = playerDetection.player
			if player != null and path.size() > 0:
				a_tick -= 1
				if a_tick == 1: 
					generate_path(player.global_position)
					a_tick = 10
				navigate(delta)
				_rotate_to_target(player.global_position, delta)
			else:
				state = SEARCH
		SEARCH:
			var player = playerDetection.player
			if player == null and path.size() > 0:
				navigate(delta)
				if path.size() > 0 and not path.size() == 2: generate_path(path[path.size()-1])
				if path.size() == 2: state = IDLE
				_rotate_to_target(path[1], delta)
			elif player != null:
				state = CHASE
			else:
				state = IDLE
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	
	if Save.game_data.experimental == true: 
		if not line2D.is_visible(): line2D.show()
		if not $DEBUG.is_visible(): $DEBUG.show()
		line2D.global_position = Vector2.ZERO
		line2D.points = path
		$DEBUG.text = str("HP%:",hp_precent,"\nState:",state,"\nStuck:",stuck," (",continuos_stuck,")\nPosition:",global_position)
		if path.size() > 1: $DEBUG.text += str("\nNext:",path[1],"\nDistance:",global_position.distance_to(path[1]))
	else:
		if line2D.is_visible(): line2D.hide()
		if $DEBUG.is_visible(): $DEBUG.hide()
	
	velocity = move_and_slide(velocity)

func _rotate_to_target(target, delta):
	var direction:Vector2 = (target - self.global_position)
	var angleTo = playerDetection.transform.x.angle_to(direction)
	playerDetection.rotate(sign(angleTo) * min(delta * rotationSpeed, abs(angleTo)))

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * DEFAULT_SPEED * slowness, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

var stuck = 0
var continuos_stuck = 0

func navigate(delta):
	if path.size() > 1:
		var direction = global_position.direction_to(path[1])
		velocity = velocity.move_toward(direction * DEFAULT_SPEED * slowness, ACCELERATION * delta)
		sprite.flip_h = velocity.x < 0
		if global_position.distance_to(path[1]) <= 4:
			path.pop_front()
			stuck = 0
			continuos_stuck = 0
		elif stuck >= 40:
			generate_path(wanderController.target_position)
			stuck = 0
			continuos_stuck += 1
		elif continuos_stuck >= 10:
			wanderController.update_target_position()
			continuos_stuck = 0
		else:
			stuck += 1
	else:
		generate_path(wanderController.target_position)

func generate_path(point:Vector2):
	if levelNavigation != null:
		path = levelNavigation.get_simple_path(global_position, point, true)

func repick_state():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1,3))
	generate_path(wanderController.target_position)

func seek_player():
	if playerDetection.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func update_health():
	$EnemyHPBar/Label.text = str(stats.health, "/", stats.max_health)
	if stats.max_health <= 80:
		$EnemyHPBar/Over.max_value = stats.max_health * 3
		$EnemyHPBar/Under.max_value = stats.max_health * 3
		$EnemyHPBar/Over.value = stats.health * 3
		$EnemyHPBar/Tween.interpolate_property($EnemyHPBar/Under, "value", $EnemyHPBar/Under.value, stats.health * 3, 0.5, Tween.TRANS_QUART, Tween.EASE_OUT)
		$EnemyHPBar/Tween.start()
	else:
		$EnemyHPBar/Over.max_value = stats.max_health
		$EnemyHPBar/Under.max_value = stats.max_health
		$EnemyHPBar/Over.value = stats.health
		$EnemyHPBar/Tween.interpolate_property($EnemyHPBar/Under, "value", $EnemyHPBar/Under.value, stats.health, 0.5, Tween.TRANS_QUART, Tween.EASE_OUT)
		$EnemyHPBar/Tween.start()

func _on_HurtBox_area_entered(area):
	randomize()
	var random = randi()%5+2
	stats.health -= area.damage
	update_health()
	var text = floating_text.instance()
	text.type = "damage"
	text.amount = area.damage
	add_child(text)
	knockback = area.knockback_vector * (knockback_base * 0.75)
	PlayerStats.set_sp(PlayerStats.sp + random)
	hurtBox.create_hit_effect()
	hurtBox.start_invincibility(.3)

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDefeatEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	PlayerStats.experience += stats.exp_reward

func sp_signal(type):
	match type:
		"slow_motion":
			knockback_base = 100
			slowness = 0.5
			$Sprite.speed_scale = 0.5
		_, "none":
			knockback_base = 200
			slowness = 1
			$Sprite.speed_scale = 1

func _on_HurtBox_invincibility_ended():
	animationPlayer.play("Stop")


func _on_HurtBox_invincibility_started():
	animationPlayer.play("Flash")
