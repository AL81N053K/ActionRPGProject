extends AudioStreamPlayer

func _ready():
# warning-ignore:return_value_discarded
	PlayerStats.connect("sp_signal", self, "sp_signal")
	
# warning-ignore:return_value_discarded
	connect("finished", self, "queue_free")

func sp_signal(type):
	if type == "slow_motion":
		self.pitch_scale = 0.5
	else:
		self.pitch_scale = 1
