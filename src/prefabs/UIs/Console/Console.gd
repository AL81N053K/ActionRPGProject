extends Control

onready var input = $Input
onready var output = $Output
onready var command_handler = $CommandHandler

var commandhistoryline = CommandHistory.history.size( )

func _ready():
	pass

func _input(event):
	if self.visible: input.grab_focus()
	if event.is_action_pressed("ui_up"):
		goto_command_history(-1)
	if event.is_action_pressed("ui_down"):
		goto_command_history(1) 

func goto_command_history(offset):
	commandhistoryline += offset
	commandhistoryline = clamp(commandhistoryline, 0, CommandHistory.history.size())
	if commandhistoryline < CommandHistory.history.size() and CommandHistory.history.size() > 0:
		input.text = CommandHistory.history[commandhistoryline]
		input.call_deferred("set_cursor_position", 99999999)

func process_command(text):
	var args = text.split(" ")
	args = Array(args)
	if args.size() <= 0: return
	
	for _i in range(args.count("")):
		args.erase("")
	
	var cmd = args.pop_front()
	
	CommandHistory.history.append(text)
	
	for c in command_handler.valid_cmd:
		if c[0] == cmd:
			if args.size() != c[1].size():
				output_text(str('Failed to execute "', cmd, '", expected ', c[1].size(), ' arguments'))
				return
			for i in range(args.size()):
				if not check_type(args[i], c[1][i]):
					output_text(str('Failed to execute "', cmd, '", argument ', (i+1), ' ("', args[i],'") is wrong type'))
					return
			output_text(command_handler.callv(cmd, args))
			return
	output_text(str('Command "', cmd, '" doesn\'t exist'))

func check_type(string, type):
	if type == command_handler.ARG_BOOL:
		return string == "true" or string == "false"
	if type == command_handler.ARG_INT:
		return string.is_valid_integer()
	if type == command_handler.ARG_FLOAT:
		return string.is_valid_float()
	if type == command_handler.ARG_STRING:
		return true
	return false

func output_text(text):
	output.text += str(text, "\n")
	output.set_v_scroll(9999999)

func _on_LineEdit_text_entered(new_text):
	input.clear()
	process_command(new_text)
	commandhistoryline = CommandHistory.history.size()
