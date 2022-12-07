extends Node

export var max_health = 1
onready var health = max_health setget set_health
var exp_reward = 1
export var exp_reward_base = 1
export var level = 1
export var life_stamp: float = 1.0

signal no_health

func set_health(value):
	health = value
	if health <= 0:
		emit_signal("no_health")

func _ready():
	$Timer.set_wait_time(life_stamp)
	$Timer.start()

func _on_Timer_timeout():
	emit_signal("no_health")
