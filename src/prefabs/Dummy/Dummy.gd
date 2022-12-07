extends KinematicBody2D

const EnemyDefeatEffect = preload("res://src/prefabs/Effects/EnemyDefeatEffect.tscn")

var floating_text = preload("res://src/prefabs/Effects/FloatingText.tscn")

const ACCELERATION = 0
const DEFAULT_SPEED = 0
const FRICTION = 0

enum {
	IDLE,
	WANDER,
	CHASE,
	SEARCH
}

onready var stats = $Stats
onready var sprite = $Sprite
onready var hurtBox = $HurtBox
onready var animationPlayer = $AnimationPlayer
onready var visibilityNotifier = $VisibilityNotifier2D

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var reset_hp = -250
var state = IDLE

func _ready():
	stats.health = 0
	visibilityNotifier.connect("screen_entered", self, "show")
	visibilityNotifier.connect("screen_exited",self,"hide")

# warning-ignore:unused_argument
func _physics_process(delta):	
	$Label.text = str(stats.health)
	
	if reset_hp < 0:
		reset_hp += 1
	if reset_hp == 0:
		var temp = stats.health
		var text = floating_text.instance()
		text.amount = temp
		text.type = "heal"
		add_child(text)
		stats.health -= temp
		reset_hp += 1
	
	velocity = move_and_slide(velocity)

func _on_HurtBox_area_entered(area):
	stats.health += area.damage
	var text = floating_text.instance()
	text.amount = area.damage
	text.type = "damage"
	add_child(text)
	reset_hp = -250
	knockback = area.knockback_vector * 150
	hurtBox.create_hit_effect()
	hurtBox.start_invincibility(PlayerStats.dummy_frames)

func _on_HurtBox_invincibility_ended():
	animationPlayer.play("Stop")

func _on_HurtBox_invincibility_started():
	animationPlayer.play("Flash")

func _on_Stats_no_health():
	pass
