extends CanvasLayer

enum TYPE { None, Protanopia, Deuteranopia, Tritanopia, Achromatopsia }
enum BLUR { None, Low, Mid, High, Ultra }

onready var rect = $Colorblindness
onready var blur = $Blur

export(TYPE) onready var Type = TYPE.None setget set_type
export(BLUR) onready var Blur = BLUR.None setget set_blur
var temp = null
var temp_b = null

func _ready():
	if self.temp:
		self.Type = self.temp
		self.temp = null
# warning-ignore:return_value_discarded
	self.get_tree().root.connect('size_changed', self, '_on_viewport_size_changed')

func set_type(value):
	if rect.material:
		rect.material.set_shader_param("type", value)
	else:
		temp = value
	Type = value

func set_blur(value):
	if blur.material:
		blur.material.set_shader_param("amount", value * 0.1)
	else:
		temp_b = value
	Blur = value

func _on_viewport_size_changed():
	self.rect.rect_min_size = self.rect.get_viewport_rect().size
