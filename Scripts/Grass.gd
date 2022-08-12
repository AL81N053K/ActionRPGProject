extends Node2D

onready var visibilityNotifier = $VisibilityNotifier2D
var GrassEffect = preload("res://Nodes/Instances/GrassEffect.tscn")

func _ready():
	hide()
	visibilityNotifier.connect("screen_entered",self,"show")
	visibilityNotifier.connect("screen_exited",self,"hide")

func create_grass_effect():
	var grassEffect = GrassEffect.instance()
	get_parent().add_child(grassEffect)
	grassEffect.position = global_position

# warning-ignore:unused_argument
func _on_HurtBox_area_entered(area):
	create_grass_effect()
	queue_free()
