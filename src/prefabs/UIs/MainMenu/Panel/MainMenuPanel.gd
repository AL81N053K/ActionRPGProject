extends TextureButton

func setup(file_name, data_text, texture, corrupted):
	self.name = file_name
	$Container/V/Texture.texture = check_texture(texture)
	$Container/V/V/SlotName.text = str(file_name)
	$Container/V/V/Data.text = data_text
	self.set_disabled(corrupted)

func getFilename():
	return $Container/V/SlotName.text

func check_texture(string:String):
	var file = File.new()
	var texture_path = str("res://Sprites/menuBackgrounds/",string,".png")
	var texture_check = file.file_exists(texture_path)
	if texture_check == true:
		return texture_path
	else:
		return null
