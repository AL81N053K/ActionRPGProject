extends CanvasModulate

var TIME_SCALE = 1
var modified_time_scale = TIME_SCALE

var time = 0
var process_mode = false
var hour = 0
var minute = 0

func _ready() -> void:
	if EventBus.connect("sp_signal", self, "sp_effect") == OK: pass

func start() -> void:
	process_mode = true
	$AnimationPlayer.play("Cycle")
	$AnimationPlayer.advance(time)

func stop() -> void:
	process_mode = false
	$AnimationPlayer.stop(false)

func reset() -> void:
	process_mode = false
	$AnimationPlayer.play("RESET")

func _process(_delta: float) -> void:
	if process_mode:
		time = $AnimationPlayer.current_animation_position
		$AnimationPlayer.playback_speed = modified_time_scale
		minute = time * 60
		hour = minute / 120

func set_time(time):
	$AnimationPlayer.seek(time, true)

func sp_effect(effect):
	if effect == "slow_motion":
		modified_time_scale = TIME_SCALE * 0.5 * 0.035
	else:
		modified_time_scale = TIME_SCALE * 1 * 0.035
		
