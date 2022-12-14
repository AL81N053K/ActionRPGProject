extends Area2D

const HitEffect = preload("res://src/prefabs/Effects/HitEffect.tscn")

var invincible = false setget set_invincible

onready var timer = $Timer
onready var collisionShape = $CollisionShape2D
onready var main = MainScene.main

signal invincibility_started
signal invincibility_ended

func set_invincible(value):
	invincible = value
	if invincible == true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)

func create_hit_effect():
	var effect = HitEffect.instance()
	self.add_child(effect)
	effect.global_position = global_position - Vector2(0, 8)


func _on_Timer_timeout():
	self.invincible = false 


func _on_HurtBox_invincibility_started():
	collisionShape.set_deferred("disabled", true)


func _on_HurtBox_invincibility_ended():
	collisionShape.set_deferred("disabled", false)
