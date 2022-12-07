extends Node

const PlayerLevelUp = preload("res://src/prefabs/Player/PlayerLevelUp.tscn")
# Health, Mana, Stamina, Special Power
var max_health: int = 1
var health: int = max_health setget set_health
var max_temp_health: int = 0
var temp_health: int = 0
var max_mana: int = 1
var mana: int = max_mana setget set_mana
var max_stamina: int = 1
var stamina: float = max_stamina setget set_stamina
var max_sp: int = 1
var sp: float = max_sp setget set_sp
# Damage
var damage: int = 0
var weapon_damage: int = 0
var base_damage: int = 1 
# Speed
var default_speed: int = 110
var speed_add: int = 0
# Defence
var defence: int = 0
var armor_defence: int = 0 
var base_defence: int = 0 

var max_exp: int = 80
var experience: int = 0
var level: int = 1

var camera_limit: bool = true
var hp_precent: float = 1.0
var no_dying: bool = false
var slowmo_usage_delay: int = 0
export var money: int = 0
var attack_speed: int = 50
var location: String = "TestingMap"
var position: Vector2 = Vector2.ZERO

var dummy_frames := 0.3

var harderer: float = 1.0
var double_power: bool = false

var challenge:String = "none"

# [name,delay,amount,one_time]
var special_powers = [
	["none",0.01,0,false],
	["slow_motion",0.1,1,false],
	["insta_heal",0.01,80,true],
	["power",1,10,false],
]

var equiped_sp = 1
var sp_on:= false
var sp_name:String
var amount:int
var delay:float
var one_time:bool

var dash:bool = false

func set_dash(value):
	dash = value

func deal_damage(value):
	if value == 0:
		EventBus.emit_signal("health_changed", "none", value)
	else:
		EventBus.emit_signal("health_changed", "damage", value)
		if temp_health < value:
			value -= temp_health
			temp_health = 0
			set_health(health - value)
		else:
			temp_health -= value

func heal(value):
	EventBus.emit_signal("health_changed", "heal", value)
	set_health(health + value)

func set_temp_health(value):
	EventBus.emit_signal("health_changed", "s_heal", value)
	temp_health = value

func set_health(value):
	if value > max_health: value = max_health
	health = value
	if health <= 0 and no_dying == false:
		EventBus.emit_signal("no_health")

func set_mana(value):
	if value > max_mana: mana = max_mana
	mana = value

func set_stamina(value):
	stamina = value
	if stamina <= 0:
		EventBus.emit_signal("no_stamina")
	if stamina >= max_stamina:
		stamina = max_stamina
		EventBus.emit_signal("stamina_refilled")

func set_sp(value):
	if value > max_sp: sp = max_sp
	sp = value

func _input(event):
	if event.is_action_pressed("special_ability") and sp > 0 and get_tree().paused == false: 
		sp_on = not sp_on

func _process(_delta):
	if dummy_frames <= 0: dummy_frames = 0.001
	
	if double_power: damage = (base_damage + weapon_damage) * 2
	else: damage = base_damage + weapon_damage
	defence = base_defence + armor_defence
	
	hp_precent = stepify(float(health) / max_health * 1.0,0.01)
	
	if level <= 10:
		max_exp = 28 * int(level * 1.09)
	if level > 10 and level <= 25:
		max_exp = 46 * int(level * 1.6)
	if level > 25 and level <= 50:
		max_exp = 73 * int(level * 1.93)
	if level > 50 and level <= 75:
		max_exp = 95 * int(level * 2.04)
	if level > 75 and level <= 100:
		max_exp = 126 * int(level * 2.5)
	if level >= 100:
		max_exp = int(162 + (level * 2.8 * harderer)) * int(level * 3.5)
	
	if sp <= 0: sp_on = false
	
	if sp_on == true:
		sp_name = special_powers[equiped_sp][0]
		delay = special_powers[equiped_sp][1]
		amount = special_powers[equiped_sp][2]
		one_time = special_powers[equiped_sp][3]
		if sp < amount: sp_on = false
	
	if sp_on == true and get_tree().paused == false:
		if $SPTimer.is_stopped() == true:
			$SPTimer.set_wait_time(delay)
			$SPTimer.start()
		EventBus.emit_signal("sp_signal", sp_name)
		if one_time == true:
			sp_on = false
	if sp_on == false:
		EventBus.emit_signal("sp_signal", "none")
	
	if experience >= max_exp:
		EventBus.emit_signal("level_up")
		randomize()
		experience -= max_exp
		level += 1
		if level % 2 == 0:
			var temp = randi()%2+1
			max_health += temp
		if level % 3 == 0:
			max_mana += 2
		if level % 2 == 0 and level < 31:
			default_speed += 4
		if level % 7 == 0:
			base_defence += 1
		if level % 8 == 0:
			max_temp_health += 5
		if level % 2 != 0 and level % 3 != 0:
			base_damage += 1
		if level < 41: 
			max_stamina += 5
		set_health(max_health)
		set_mana(max_mana)
		set_stamina(max_stamina)
		if level > 999:
			harderer += 0.05
		if level > 1999:
			harderer += 0.1
		if level > 4999:
			harderer += 1
		var playerLevelUp = PlayerLevelUp.instance()
		if self.has_node("PlayerLevelUp") == false:
			self.add_child(playerLevelUp)
	
	match challenge:
		"1_hp":
			_1_hp()
		_:
			pass
	

func _1_hp():
	if max_health > 1:
		var temp = max_health - 1
		max_temp_health += temp
		temp_health += temp
		health = 1
		max_health = 1

func _on_SPTimer_timeout():
	set_sp(sp - amount)
