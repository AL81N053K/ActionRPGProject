extends Node

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

export(float, 0, 1000) var amplitude: float = 0.0
var priority = 0
onready var camera = get_parent()
var _shake = 0

func start(duration = 0.2, frequency = 15, _amplitude = 16, _priority = 0):
	if priority >= self.priority:
		self.priority = _priority
		self.amplitude = _amplitude
		$Duration.wait_time = duration
		$Frequency.wait_time = 1 / float(frequency)
		$Duration.start()
		$Frequency.start()
		_new_shake()

func _new_shake():
	var rand = Vector2.ZERO
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	rand.x = rng.randf_range(-amplitude,amplitude)
	rng.randomize()
	rand.y = rng.randf_range(-amplitude,amplitude)
	
	$ShakeTween.interpolate_property(camera, "offset", camera.get_offset(), rand, $Frequency.wait_time, TRANS, EASE)
	$ShakeTween.start()
	_shake += 1

func _reset():
	$ShakeTween.interpolate_property(camera, "offset", camera.offset, Vector2.ZERO, $Frequency.wait_time, TRANS, EASE)
	$ShakeTween.start()
	self.priority = 0
	_shake = 0

func _on_Frequency_timeout():
	_new_shake()


func _on_Duration_timeout():
	_reset()
	$Frequency.stop()
