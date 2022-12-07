extends Sprite

func _ready():
	$AlphaTween.interpolate_property(self, "self_modulate", Color(1, 1, 1, 1), Color(0, 0, 1, 0), 0.6, Tween.TRANS_SINE, Tween.EASE_OUT)
	$AlphaTween.start()

# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_AlphaTween_tween_completed(object, key):
	queue_free()
