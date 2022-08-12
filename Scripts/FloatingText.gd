extends Position2D

onready var label = $Label
onready var tween = $Tween
var amount = 0
var type = ""
var velocity = Vector2.ZERO
var max_size = Vector2(1,1)

func _ready():
	label.set_text(str(amount))
	match type:
		"heal":
			label.set("custom_colors/font_color", Color(.1,.8,.1))
		"damage":
			label.set("custom_colors/font_color", Color(.8,.1,.1))
		"crit":
			label.set("custom_colors/font_color", Color(.7,.7,.1))
		"poison":
			label.set("custom_colors/font_color", Color(.7,.1,.7))
		_:
			label.set("custom_colors/font_color", Color(1,1,1))
	randomize()
	var slide_movement = randi() % 101 - 50
	velocity = Vector2(slide_movement, 25)
	tween.interpolate_property(self, 'scale', scale, max_size,0.2,Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'scale', max_size, Vector2(.1,.1),0.7,Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.3)
	tween.start()

func _process(delta):
	if type == "heal":
		position -= velocity * delta
	else:
		position += velocity * delta

func _on_Tween_tween_all_completed():
	self.queue_free()
