extends Control

onready var _bar_begin = $Base
onready var _bar_end = $Base/End
onready var _size = $Size
onready var _progress = $Progress
onready var _max = $Max
onready var _label = $Label

func _ready():
	_size.grab_focus()
	_progress.max_value = _max.value

func _process(_delta):
	_bar_begin.value = _progress.value
	_bar_end.value = _progress.value
	
	_bar_end.max_value = _progress.max_value
	var _bar_size = _bar_begin.get_size().x
	var _a = stepify(_bar_size / (_bar_size + 16),0.01)
	var _b = stepify(1 - _a,0.01)
	
	_bar_begin.max_value = int(_a * _max.value)
	_bar_end.min_value = int(_a * _max.value)
	
	_label.text = str("Size:",_bar_size,"|Value:",_progress.value,"|Max Value:",_max.value,"\n_a:",_a,"|_b:",_b)

func _on_Progress_value_changed(_value):
	pass

func _on_Size_value_changed(value):
	_bar_begin.set_stretch_margin(MARGIN_LEFT, value)

func _on_Max_value_changed(value):
	_progress.max_value = value
