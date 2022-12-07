extends AudioStreamPlayer

func _ready():
	if EventBus.connect("sp_signal", self, "sp_signal") == OK: pass
	if connect("finished", self, "queue_free") == OK: pass

func sp_signal(type):
	if type == "slow_motion":
		self.pitch_scale = 0.5
	else:
		self.pitch_scale = 1
