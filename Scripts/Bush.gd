extends StaticBody2D

onready var visibilityNotifier = $VisibilityNotifier2D

func _ready():
	visibilityNotifier.connect("screen_entered", self, "show")
	visibilityNotifier.connect("screen_exited",self,"hide")
