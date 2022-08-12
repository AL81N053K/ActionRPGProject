extends Node

var main_name:String = "" setget setName
var main:Node = self

func setName(value):
	main_name = str(value)
	main = get_parent().get_node(str(main_name))
