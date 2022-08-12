extends Area2D

export (String) var destination = ""
export (bool) var mute_music = false

func _on_Teleport_body_entered(body):
	var _transition_rect := self.get_parent().get_parent().get_node("CanvasLayer/SceneTransitionRect")
	_transition_rect.transition()
	body.state = "NONE"
	yield(_transition_rect,"animation_finished")
	var dir = Directory.new()
	if dir.file_exists(destination):
		SceneChanger.goto_scene(destination, MainScene.main)
		if mute_music: Music.SetGameState("Loading")
	else:
		SceneChanger.goto_scene("res://Maps/MainMenu.tscn", MainScene.main)
