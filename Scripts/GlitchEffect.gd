extends ColorRect

export var color_rate = 0.0 
export var power = 0.0 
var working = true

func _ready():
# warning-ignore:return_value_discarded
	GlobalSettings.connect("glitch_effect", self, "_toggle")

func _toggle(value):
	working = value

# warning-ignore:unused_argument
func _process(delta):
	if working:
		if PlayerStats.hp_precent <= .25:
			color_rate = clamp((1 - (PlayerStats.hp_precent * 4))*.002, 0, 0.005)
			power = clamp((1 - (PlayerStats.hp_precent * 4))*.005, 0, 0.02)
		else:
			color_rate = 0
			power = 0
	else:
		color_rate = 0
		power = 0
	self.material.set_shader_param("shake_power", power)
	self.material.set_shader_param("shake_color_rate", color_rate)
		
