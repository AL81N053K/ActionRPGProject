extends Control

onready var fps = $MarginContainer/VBoxContainer/FPS
onready var ram = $MarginContainer/VBoxContainer/RAM
var fps_cap = 0
var _fps = 0
var _ram_usage = 0
var _ram_peak = 0

func _ready():
# warning-ignore:return_value_discarded
	GlobalSettings.connect("fps_display", self, "_display_changed")
# warning-ignore:return_value_discarded
	GlobalSettings.connect("fps_cap", self, "_fps_check")
	self.visible = Save.game_data.display_fps
	_fps_check(Save.game_data.limit_fps)

# warning-ignore:unused_argument
func _process(delta):
	_fps = Engine.get_frames_per_second()
	_ram_usage = stepify(OS.get_static_memory_usage() / 1000000.0, 0.001)
	
	if _ram_usage >= _ram_peak:
		ram.self_modulate = Color(1,1,0.3)
	else:
		ram.self_modulate = Color(1,1,1)
	
	_ram_peak = stepify(OS.get_static_memory_peak_usage() / 1000000.0,0.001)
	
	fps.text = str(_fps, " FPS")
	ram.text = str(_ram_usage, " MB RAM\n", _ram_peak ," MB RAM (peak)")
	
	if _fps >= fps_cap:
		fps.self_modulate = Color(.3,1,.3)
	if _fps >= int(fps_cap * 0.75) and _fps < fps_cap:
		fps.self_modulate = Color(.5,1,.3)
	if _fps >= int(fps_cap * 0.5) and _fps < int(fps_cap * 0.75):
		fps.self_modulate = Color(1,1,.3)
	if _fps >= int(fps_cap * 0.25) and _fps < int(fps_cap * 0.5):
		fps.self_modulate = Color(1,.5,.3)
	if _fps < int(fps_cap * 0.25):
		fps.self_modulate = Color(1,.3,.3)
	if fps_cap == 0:
		fps.self_modulate = Color(1,1,1)

func _fps_check(value):
	fps_cap = value

func _display_changed(value):
	self.visible = value

