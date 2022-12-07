extends ColorRect

onready var tween = $Tween
var alpha = 0.0

func _ready():
	if EventBus.connect("sp_signal",self,"sp_signal") == OK: pass

func _process(_delta):
	self.material.set_shader_param("alpha", alpha)

func sp_signal(type):
	if type == "slow_motion" and alpha == 0:
		tween.interpolate_property(self,"alpha", 0, 0.75, .5, Tween.TRANS_QUART, Tween.EASE_OUT)
	elif type != "slow_motion" and alpha == 0.75:
		tween.interpolate_property(self,"alpha", 0.75, 0, .5, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()
