extends Area2D

export (String) var destination = ""
export (bool) var mute_music = false

func _on_Teleport_body_entered(body):
	Transition.transition()
	body.state = 0
	yield(Transition,"animation_finished")
	var dir = Directory.new()
	if dir.file_exists(destination):
		SceneChanger.goto_scene(destination, MainScene.main)
		if mute_music: Music.SetGameState("Loading")
	else:
		SceneChanger.goto_scene("res://src/maps/MainMenu.tscn", MainScene.main)
