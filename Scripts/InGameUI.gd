extends Control

onready var hptext = $V/V/HP/Over/Label
onready var bhptext = $V/V/BHP/Over/Label
onready var mptext = $V/MP/Over/Label
onready var exptext = $Back/Container/EXP/Level

onready var hpOver = $V/V/HP/Over
onready var hpUnder = $V/V/HP/Under
onready var bhpOver = $V/V/BHP/Over
onready var bhpUnder = $V/V/BHP/Under
onready var mpOver = $V/MP/Over
onready var mpUnder = $V/MP/Under
onready var spOver = $Back/Container/SP/Over
onready var spUnder = $Back/Container/SP/Under
onready var expBar = $Back/Container/EXP

onready var hptween = $V/V/HP/Tween
onready var bhptween = $V/V/BHP/Tween
onready var manatween = $V/MP/Tween
onready var sptween = $Back/Container/SP/Tween
onready var exptween = $Back/Container/EXP/Tween

const stats = PlayerStats

func _process(_delta):
	hptext.text = str(stats.health, "/", stats.max_health, " (", stats.hp_precent , ")")
	bhptext.text = str(stats.temp_health, "/", stats.max_temp_health)
	mptext.text = str(stats.mana, "/", stats.max_mana)
	exptext.text = str(stats.level)
	
	hpUnder.max_value = stats.max_health
	hpOver.max_value = stats.max_health
	bhpUnder.max_value = stats.max_temp_health
	bhpOver.max_value = stats.max_temp_health
	mpUnder.max_value = stats.max_mana
	mpOver.max_value = stats.max_mana
	spUnder.max_value = stats.max_sp
	spOver.max_value = stats.max_sp
	expBar.max_value = stats.max_exp
	hpOver.value = stats.health
	bhpOver.value = stats.temp_health
	mpOver.value = stats.mana
	spOver.value = stats.sp
	make_tween("hp",hpUnder, "value", hpUnder.value, PlayerStats.health)
	make_tween("bhp",bhpUnder, "value", bhpUnder.value, PlayerStats.temp_health)
	make_tween("mp",mpUnder, "value", mpUnder.value, PlayerStats.mana)
	make_tween("sp",spUnder, "value", spUnder.value, PlayerStats.sp)
	make_tween("xp",expBar, "value", expBar.value, PlayerStats.experience)
	
	if PlayerStats.temp_health > 0: 
		$V/V/BHP.show()
		hptext.hide()
	if PlayerStats.temp_health <= 0: 
		hptext.show()
		$V/V/BHP.hide()
	
	hptween.start()
	bhptween.start()
	manatween.start()
	sptween.start()
	exptween.start()

func make_tween(tween: String, item, property: String, from, to):
	if tween == "hp" and hptween.is_active() == false:
		hptween.interpolate_property(item, property, from, to, .1, Tween.TRANS_LINEAR)
	if tween == "bhp" and bhptween.is_active() == false:
		bhptween.interpolate_property(item, property, from, to, .1, Tween.TRANS_LINEAR)
	if tween == "mp" and manatween.is_active() == false:
		manatween.interpolate_property(item, property, from, to, .1, Tween.TRANS_LINEAR)
	if tween == "sp" and sptween.is_active() == false:
		sptween.interpolate_property(item, property, from, to, .1, Tween.TRANS_LINEAR)
	if tween == "xp" and exptween.is_active() == false:
		exptween.interpolate_property(item, property, from, to, .1, Tween.TRANS_LINEAR)
