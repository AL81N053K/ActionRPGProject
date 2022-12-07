extends MarginContainer

export(Color) var color = Color(1,1,1,1)
onready var over = $Over
onready var under = $Under

func _ready() -> void:
	over.tint_over = color
	over.tint_progress = color
	over.tint_under = color
	under.tint_over = color
	under.tint_progress = color
	under.tint_under = color
