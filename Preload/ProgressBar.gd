extends CanvasLayer

func _ready():
	$Tween.interpolate_property($Clock,"modulate",Color(1,1,1,0),Color(1,1,1,1),.2,Tween.TRANS_LINEAR)
	$Tween.start()
# warning-ignore:return_value_discarded
	SceneChanger.connect("loaded",self,"loaded")
	$Clock/Hand/AnimationPlayer.play("repeat")
	$Clock/Hand2/AnimationPlayer.play("repeat")

func loaded():
	$Tween.interpolate_property($Clock,"modulate",Color(1,1,1,1),Color(1,1,1,0),.2,Tween.TRANS_LINEAR)
	$Tween.start()
	$Clock/Hand/AnimationPlayer.stop()
	$Clock/Hand2/AnimationPlayer.stop()
	yield($Tween,"tween_all_completed")
	queue_free()
