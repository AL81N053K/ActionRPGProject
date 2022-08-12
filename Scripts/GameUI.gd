extends CanvasLayer

onready var basicStuff = $InGameUI
onready var pauseMenu = $PauseMenu
onready var inventory = $Inventory
onready var console = $Console
onready var cmd = $Console/Input

func _ready():
	pauseMenu.visible = false
	inventory.visible = false
	console.visible = false

# warning-ignore:unused_argument
func _input(event):
	if Input.is_action_just_pressed("inventory") and pauseMenu.visible == false and console.visible == false:
		inventory.visible = not inventory.visible
		pauseMenu.visible = false
		console.visible = false
		basicStuff.visible = true
		get_tree().paused = inventory.visible
	if pauseMenu.get_node("Options").visible == false and console.visible == false and Input.is_action_just_pressed("menu"):
		$PauseMenu/Buttons/Resume.grab_focus()
		pauseMenu.visible = !pauseMenu.visible
		inventory.visible = false
		console.visible = false
		basicStuff.visible = not pauseMenu.visible
		get_tree().paused = pauseMenu.visible
	if Input.is_action_just_pressed("console") and console.visible == false and pauseMenu.visible == false and Save.game_data.debug_console == true:
		console.visible = true
		if inventory.visible == false: get_tree().paused = console.visible
	if Input.is_action_just_pressed("menu") and console.visible == true:
		console.visible = false
		if inventory.visible == false: get_tree().paused = console.visible
