extends KinematicBody2D

const ACCELERATION = 5000
export var DEFAULT_SPEED = 50
const FRICTION = 0

onready var stats = $Stats
onready var sprite = $Sprite
onready var playerDetection = $PlayerDetection
onready var hurtBox = $HurtBox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var knockback_base: int = 0
var slowness = 1.0
var direction:Vector2
var target:Vector2 = Vector2.ZERO
var dmg_decreased = false

func _ready():
	stats.max_health = stats.max_health * stats.level
	stats.health = stats.max_health
	if EventBus.connect("sp_signal",self,"sp_signal") == OK: pass
	var angle = Vector2(0,0).angle_to_point(direction)
	rotation_degrees = rad2deg(angle) + 90
	$Sprite.self_modulate = $Sprite.self_modulate * 1.25
	if $Timer.connect("timeout",self,"decrease_dmg") == OK: pass

func _physics_process(delta):
	var time_left:float = float(stats.get_node("Timer").get_time_left() / stats.life_stamp)
	if time_left <= .25: sprite.modulate.a = time_left * 4
	knockback = knockback.move_toward(Vector2.ZERO, knockback_base * delta)
	knockback = move_and_slide(knockback)
	stats.exp_reward = stats.exp_reward_base * stats.level
	target = direction
	accelerate_towards_point(target, delta)
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func accelerate_towards_point(point, delta):
	velocity = velocity.move_toward(point * DEFAULT_SPEED * slowness, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func sp_signal(type):
	match type:
		"slow_motion":
			slowness = 1
			$Sprite.speed_scale = 1
		_, "none":
			slowness = 1
			$Sprite.speed_scale = 1

func _on_HurtBox_area_entered(area):
	randomize()
	var random = randi()%2+1
	stats.health -= area.damage
	knockback = area.knockback_vector * (knockback_base * 0.75)
	PlayerStats.set_sp(PlayerStats.sp + random)
	hurtBox.create_hit_effect()
	hurtBox.start_invincibility(0)

func _on_Stats_no_health():
	hide()
	queue_free()

func _on_HurtBox_invincibility_ended():
	animationPlayer.play("Stop")

func _on_HurtBox_invincibility_started():
	animationPlayer.play("Flash")

func _on_HitBox_area_entered(area):
	var hit = area.get_node_or_null("../Stats")
	if hit != null:
		stats.health -= $HitBox.damage
		$Timer.start(.01)

func decrease_dmg():
	$HitBox.damage = clamp($HitBox.damage / 1.5,1,$HitBox.damage)
