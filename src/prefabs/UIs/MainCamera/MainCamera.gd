extends Camera2D

onready var topleft = $"Limits/TopLeft Limit"
onready var bottomright = $"Limits/BottomRight Limit"

func _ready():
	current = true

func _process(_delta):
	if PlayerStats.camera_limit == true and limit_top == -10000000:
		limit_on()
	elif  PlayerStats.camera_limit == false and limit_top != -10000000:
		limit_off()

func limit_on():
	limit_top = topleft.position.y
	limit_left = topleft.position.x
	limit_bottom = bottomright.position.y
	limit_right = bottomright.position.x

func limit_off():
	limit_top = -10000000
	limit_left = -10000000
	limit_bottom = 10000000
	limit_right = 10000000
