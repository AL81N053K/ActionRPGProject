extends "res://Scripts/EnemyBase.gd"

var heal_timer = 0

func _physics_process(_delta):
	if state == CHASE:
		if stats.health < stats.max_health:
			heal_timer += 1
			if heal_timer > 125:
				heal_timer -= 125
				stats.health += 15
				var text = floating_text.instance()
				text.type = "heal"
				text.amount = 15
				add_child(text)
				if stats.health > stats.max_health:
					stats.health = stats.max_health
