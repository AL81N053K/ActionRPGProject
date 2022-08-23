extends Node

onready var bg_music_mm = $BackgroundMainMenu
onready var bg_music_n = $BackgroundNormal
onready var bg_music_c = $BackgroundCombat
onready var tween_mm = $BackgroundMainMenu/Tween
onready var tween_n = $BackgroundNormal/Tween
onready var tween_c = $BackgroundCombat/Tween

var game_state setget SetGameState
var pitch:float = 1
var pitch_sp:float = 1
var check:bool
var player:Node

func _ready():
	SetGameState("NewGame")
# warning-ignore:return_value_discarded
	PlayerStats.connect("sp_signal",self,"sp_signal")

func _process(_delta):
	pitch = 1 * pitch_sp
	
	if bg_music_n.pitch_scale != pitch:
		make_tween("n","pitch_scale",bg_music_n.pitch_scale,pitch,.1)
		make_tween("c","pitch_scale",bg_music_c.pitch_scale,pitch,.1)

func sp_signal(type):
	if type == "slow_motion":
		pitch_sp = 0.5
	else:
		pitch_sp = 1

func SetGameState(new_value):
	if not game_state == new_value:
		game_state = new_value
		ChangeMusic()

func ChangeMusic():
	match game_state:
		"NewGame":
			bg_music_mm._set_playing(true)
			make_tween("mm","volume_db",bg_music_mm.volume_db, -15, 2, Tween.TRANS_QUART, Tween.EASE_OUT)
		"MainMenu":
			tween_mm.remove_all()
			tween_n.remove_all()
			tween_c.remove_all()
			bg_music_mm._set_playing(true)
			make_tween("mm","volume_db",bg_music_mm.volume_db, -15, 2, Tween.TRANS_QUART, Tween.EASE_OUT)
			make_tween("n","volume_db",bg_music_n.volume_db, -60, .5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			make_tween("c","volume_db",bg_music_c.volume_db, -60, .5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		"Loading":
			tween_mm.remove_all()
			tween_n.remove_all()
			tween_c.remove_all()
			make_tween("mm","volume_db",bg_music_mm.volume_db, -60, .5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			make_tween("n","volume_db",bg_music_n.volume_db, -60, .5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			make_tween("c","volume_db",bg_music_c.volume_db, -60, .5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		"Explore":
			tween_n.remove_all()
			tween_c.remove_all()
			make_tween("combat","volume_db",bg_music_c.volume_db, -60, 3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			if not bg_music_n.is_playing(): bg_music_n._set_playing(true)
			make_tween("normal","volume_db",bg_music_n.volume_db, -15, 2, Tween.TRANS_QUART, Tween.EASE_IN, 1)
		"Combat":
			tween_n.remove_all()
			tween_c.remove_all()
			make_tween("normal","volume_db",bg_music_n.volume_db, -60, .8, Tween.TRANS_QUART, Tween.EASE_OUT)
			if not bg_music_c.is_playing(): bg_music_c._set_playing(true)
			make_tween("combat","volume_db",bg_music_c.volume_db, -15, .5, Tween.TRANS_LINEAR, Tween.EASE_IN)
			CheckCombat()

func CheckCombat():
	if PlayerStats.health > 0: player = MainScene.main.get_node_or_null("YSort/Player")
	else: player = null
	if player != null: check = player.in_combat_check()
	if player == null: SetGameState("Loading")
	$Timer.start()

func make_tween(tween:String, param:String, init, final:float, duration:float, transition = Tween.TRANS_LINEAR, _ease = Tween.EASE_IN, delay:float = 0):
	match tween:
		"normal", "n":
			tween_n.interpolate_property(bg_music_n, param, init, final, duration, transition, _ease, delay)
			tween_n.start()
		"mainmenu", "mm":
			tween_mm.interpolate_property(bg_music_mm, param, init, final, duration, transition, _ease, delay)
			tween_mm.start()
		"combat", "c":
			tween_c.interpolate_property(bg_music_c, param, init, final, duration, transition, _ease, delay)
			tween_c.start()

func _on_Tween_Normal_tween_all_completed():
	if bg_music_n.volume_db == -60:
		bg_music_n._set_playing(false)

func _on_Tween_Combat_tween_all_completed():
	if bg_music_c.volume_db == -60:
		bg_music_c._set_playing(false)

func _on_Tween_MainMenu_tween_all_completed():
	if bg_music_mm.volume_db == -60:
		bg_music_mm._set_playing(false)

func _on_Timer_timeout():
	if check and player != null:
		CheckCombat()
	if !check and player != null:
		SetGameState("Explore")
