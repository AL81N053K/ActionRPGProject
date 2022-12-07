extends Panel

var slot_unsel: StyleBoxTexture = preload("res://assets/sprites/inventory/slot.tres")
var slot_sel: StyleBoxTexture = preload("res://assets/sprites/inventory/slot_selected.tres")
var slot_empty_unsel: StyleBoxTexture = preload("res://assets/sprites/inventory/slot_empty.tres")
var slot_empty_sel: StyleBoxTexture = preload("res://assets/sprites/inventory/slot_empty_selected.tres")

var textures = [slot_empty_sel, slot_empty_unsel, slot_sel, slot_unsel]

func _set_texture(name) -> void:
	name = get(name)
	if textures.has(name):
		set('custom_styles/panel',name)
	else:
		print("You goof'd up")
