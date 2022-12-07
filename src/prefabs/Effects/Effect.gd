extends AnimatedSprite

func _ready():
	if connect("animation_finished", self, "_on_animation_finished") == OK: pass
	if EventBus.connect("sp_signal", self, "sp_signal") == OK: pass
	frame = 0
	play("default")

func _on_animation_finished():
	queue_free()

func sp_signal(type):
	if type == "slow_motion":
		$AudioStreamPlayer.pitch_scale = 0.5
	else:
		$AudioStreamPlayer.pitch_scale = 1.0
