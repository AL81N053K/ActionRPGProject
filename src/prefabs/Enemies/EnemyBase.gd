extends KinematicBody2D

const EnemyDefeatEffect = preload("res://src/prefabs/Effects/EnemyDefeatEffect.tscn")

signal target_reached
signal path_changed(path)

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
onready var line2D = $Line2D
onready var navigation_agent = $NavigationAgent2D
onready var _timer = $Timer

onready var stats = $Stats
onready var sprite = $Sprite
onready var playerDetection = $PlayerDetection
onready var hurtBox = $HurtBox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer
onready var visibilityNotifier = $VisibilityNotifier2D

onready var navigation: Navigation2D = null

var floating_text = preload("res://src/prefabs/Effects/FloatingText.tscn")

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var move_direction = Vector2.ZERO
var _target = Vector2.ZERO
var state = IDLE
var knockback_base: int = 200
var slowness = 1.0
var rotationSpeed = 2.0
var did_arrive = false
var lose_interest = 0
var max_lose_interest = 1500

func _ready():
	hide()
	stats.max_health = stats.max_health * stats.level
	stats.health = stats.max_health
	update_health()
	if EventBus.connect("sp_signal",self,"sp_signal") == OK: pass
	visibilityNotifier.connect("screen_entered", self, "show")
	visibilityNotifier.connect("screen_exited",self,"hide")
	
	navigation_agent.connect("path_changed", self, "_on_NavigationAgent2D_path_changed")
	navigation_agent.connect("velocity_computed", self, "_on_NavigationAgent2D_velocity_computed")
	
	yield(get_tree(), "idle_frame")
	if get_tree().has_group("navigation"):
		navigation = get_tree().get_nodes_in_group("navigation")[0]
		navigation_agent.set_navigation(navigation)
	set_target_location(global_position)
	

func _physics_process(delta):
	if not visible:
		return
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
			did_arrive = true
			seek_player()
			if wanderController.get_time_left() == 0:
				repick_state()
		WANDER:
			seek_player()
			move(delta)
			if _arrived_at_location():
				state = IDLE
			lose_interest = 0
		CHASE:
			Music.SetGameState("Combat")
			var player = playerDetection.player
			if player != null:
				move(delta)
				if _timer.time_left <= 0.01 and _target != player.global_position:
					set_target_location(player.global_position)
			else:
				state = SEARCH
			lose_interest += 1
			if lose_interest >= max_lose_interest: 
				lose_interest = 0
				state = IDLE
		SEARCH:
			var player = playerDetection.player
			move(delta)
			if player == null and _arrived_at_location() == false: pass
			elif player != null: state = CHASE
			else: state = IDLE
			lose_interest += 1
			if lose_interest >= max_lose_interest: 
				lose_interest = 0
				state = IDLE
	
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	
	experimental(hp_precent)
	navigation_agent.set_velocity(velocity)
	velocity = move_and_slide(velocity)

func set_target_location(target:Vector2) -> void:
	did_arrive = false
	_target = target
	navigation_agent.set_target_location(target)
	path = navigation_agent.get_nav_path()

func look_at_direction(direction:Vector2) -> void:
	direction = direction.normalized()
	move_direction = direction

func rotate_to_target(target, delta):
	var direction:Vector2 = (target - self.global_position)
	var angleTo = playerDetection.transform.x.angle_to(direction)
	playerDetection.rotate(sign(angleTo) * min(delta * rotationSpeed, abs(angleTo)))

func move(delta):
	move_direction = global_position.direction_to(navigation_agent.get_next_location())
	rotate_to_target(navigation_agent.get_target_location(), delta)
	sprite.flip_h = velocity.x < 0
	velocity = velocity.move_toward((move_direction * DEFAULT_SPEED * slowness) / 2, ACCELERATION * delta)

func repick_state():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1,3))
	set_target_location(wanderController.target_position)

func seek_player():
	if playerDetection.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _arrived_at_location() -> bool:
	return navigation_agent.is_navigation_finished()

func experimental(hp_precent):
	if Save.game_data.experimental and visible: 
		if not line2D.is_visible(): line2D.show()
		if not $DEBUG.is_visible(): $DEBUG.show()
		line2D.global_position = Vector2.ZERO
		line2D.points =  navigation_agent.get_nav_path()
		$DEBUG.text = str("HP%:",hp_precent,"\nS:",state,"\nPos:",global_position,"\nT:",navigation_agent.get_target_location(),"\nWT:",wanderController.target_position,"\nLI:",stepify(float(lose_interest)/max_lose_interest,.01))
	else:
		if line2D.is_visible(): line2D.hide()
		if $DEBUG.is_visible(): $DEBUG.hide()

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

func _on_HurtBox_invincibility_ended():
	animationPlayer.play("Stop")

func _on_HurtBox_invincibility_started():
	animationPlayer.play("Flash")

func _on_NavigationAgent2D_velocity_computed(safe_velocity: Vector2) -> void:
	if not _arrived_at_location():
		velocity = move_and_slide(safe_velocity)
	elif not did_arrive:
		did_arrive = true
		emit_signal("path_changed", [])
		emit_signal("target_reached")

func _on_NavigationAgent2D_path_changed() -> void:
	emit_signal("path_changed", navigation_agent.get_nav_path())
