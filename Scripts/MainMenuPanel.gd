extends TextureButton

export var slot_number:int = 1
var corrupted:bool = false
var c_texture_name:String = "default"
var c_data_text:String = ""

onready var slotName = $Container/V/SlotName
onready var texture = $Container/V/Texture
onready var data = $Container/V/Data

func _ready():
	set_names()

func set_names():
	slotName.text = str("Slot ", slot_number) 
	data.text = c_data_text
	texture.texture = load(check_texture(c_texture_name))
	self.set_disabled(corrupted)

func check_texture(string:String):
	var file = File.new()
	var texture_path = str("res://Sprites/menuBackgrounds/",string,".png")
	var texture_check = file.file_exists(texture_path)
	if texture_check == true:
		return texture_path
	else:
		return "default"
