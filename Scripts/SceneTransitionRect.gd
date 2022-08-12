extends TextureRect

# Reference to the _AnimationPlayer_ node
onready var _anim_player = $AnimationPlayer
signal animation_finished

func _ready():
# warning-ignore:return_value_discarded
	SceneChanger.connect("loaded", self, "transition_backwards")
	transition_backwards()

func transition() -> void:
	_anim_player.play("Fade")
	yield(_anim_player, "animation_finished")
	emit_signal("animation_finished")

func transition_backwards() -> void:
	_anim_player.play_backwards("Fade")
