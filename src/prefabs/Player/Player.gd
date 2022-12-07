extends KinematicBody2D

const PlayerHurtSound = preload("res://src/prefabs/Player/PlayerHurtSound.tscn")
const Projectile = preload("res://src/prefabs/Projectiles/SwishProjectile.tscn")

const ACCELERATION = 600
const FRICTION = 1000

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $Position2D/HitBox
onready var hurtBox = $HurtBox
onready var flashEffect = $FlashEffect
onready var staminaCircle = $Stamina/Circle
onready var staminaCircleTween = $Stamina/Circle/Tween
onready var staminaCircleUnder = $Stamina/Circle/Under
onready var staminaCircleOver = $Stamina/Circle/Over
onready var staminaBar = $Stamina/Bar
onready var staminaBarTween = $Stamina/Bar/Tween
onready var staminaBarUnder = $Stamina/Bar/Under
onready var staminaBarOver = $Stamina/Bar/Over
onready var spriteTween = $PlayerSprite/Tween
var rng = RandomNumberGenerator.new()
var floating_text = preload("res://src/prefabs/Effects/FloatingText.tscn")

enum {
	NONE,
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var stats = PlayerStats

var roll_vector = Vector2.DOWN
var calc_speed
var speed_add
var walkTimeScale: float = 1.0
var attackTimeScale: float = 1.0
var rollTimeScale: float = 1.0
var speed_modifier = 1.0
var speed_modifier_health = 1.0
var out_of_stamina = false
var stamina_cooldown: int = -200
var slowmo:bool = false
var die = false

func _ready():
	randomize()
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector
	if EventBus.connect("sp_signal", self, "sp_signal") == OK: pass
	if EventBus.connect("no_stamina", self, "no_stamina") == OK: pass
	if EventBus.connect("stamina_refilled", self, "stamina_refilled") == OK: pass
	if EventBus.connect("no_health", self, "no_health") == OK: pass
	if EventBus.connect("health_changed", self, "health_changed") == OK: pass
	if EventBus.connect("set_stamina_bar_style", self, "set_stamina_bar_style") == OK: pass
	flashEffect.play("Stop")
	state = MOVE
	$HurtBox/CollisionShape2D.set_deferred("disabled", false)
	staminaCircle.modulate = Color(1,1,1,0.9)
	staminaBar.modulate = Color(1,1,1,0.9)

func _on_joy_connection_changed(device_id, connected):
	if connected:
		print(Input.get_joy_name(device_id)," device")
	else:
		print("Keyboard")

func _physics_process(delta):
	var DEFAULT_SPEED = stats.default_speed
	speed_add = stats.speed_add
	swordHitbox.damage = stats.damage
	calc_speed = float((DEFAULT_SPEED + speed_add) * speed_modifier * speed_modifier_health)
	walkTimeScale = float(((calc_speed / speed_modifier) * (clamp(speed_modifier * 0.5, 1.0, 2.5))) / 140)
	attackTimeScale = float(stats.attack_speed / 50.0)
	rollTimeScale = 1.0
	
	animationTree.set("parameters/Walk/TimeScale/scale", walkTimeScale)
	animationTree.set("parameters/Roll/TimeScale/scale", rollTimeScale)
	animationTree.set("parameters/Dash/TimeScale/scale", rollTimeScale)
	animationTree.set("parameters/SwordAttack/TimeScale/scale", attackTimeScale)
	
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)
	
	if PlayerStats.stamina <= 0:
		out_of_stamina = true
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		stamina_cooldown -= 10
	
	if Input.is_action_pressed("roll") and out_of_stamina == false:
		if state != ROLL:
			stamina_cooldown = -200
			stats.set_stamina(stats.stamina - 10)
		state = ROLL
	
	if stats.stamina < stats.max_stamina: stamina_cooldown += 1
	if stats.stamina > stats.max_stamina: stats.stamina = stats.max_stamina
	
	staminaCircleUnder.max_value = stats.max_stamina
	staminaCircleOver.max_value = stats.max_stamina
	staminaCircleOver.value = stats.stamina
	staminaBarUnder.max_value = stats.max_stamina
	staminaBarOver.max_value = stats.max_stamina
	staminaBarOver.value = stats.stamina
	
	if stamina_cooldown > 0 and stats.stamina < stats.max_stamina: stats.set_stamina(stats.stamina + stats.max_stamina * 0.01 * Engine.time_scale)
	
	var staminaPercentage = (stats.stamina/stats.max_stamina)*100 
	
	if staminaCircle.visible == true:
		make_tween("circle",staminaCircleUnder,"value",staminaCircleUnder.value,stats.stamina)
		if stats.stamina < stats.max_stamina and staminaCircle.modulate == Color(1,1,1,0):
			make_tween("circle",staminaCircle,"modulate",Color(1,1,1,0),Color(1,1,1,.9))
		if stats.stamina >= stats.max_stamina and staminaCircle.modulate == Color(1,1,1,.9):
			make_tween("circle",staminaCircle,"modulate",Color(1,1,1,.9),Color(1,1,1,0))
		if staminaPercentage > 20 and out_of_stamina == false:
			staminaCircleOver.set_tint_progress(Color(.17,1,0))
		elif staminaPercentage <= 20 or out_of_stamina == true:
			staminaCircleOver.set_tint_progress(Color(1,.17,0))
	if staminaBar.visible == true:
		make_tween("bar",staminaBarUnder,"value",staminaBarUnder.value,stats.stamina)
		if stats.stamina < stats.max_stamina and staminaBar.modulate == Color(1,1,1,0):
			make_tween("bar",staminaBar,"modulate",Color(1,1,1,0),Color(1,1,1,.9))
		if stats.stamina >= stats.max_stamina and staminaBar.modulate == Color(1,1,1,.9):
			make_tween("bar",staminaBar,"modulate",Color(1,1,1,.9),Color(1,1,1,0))
		if staminaPercentage > 20 and out_of_stamina == false:
			staminaBarOver.set_tint_progress(Color(.17,1,0))
		elif staminaPercentage <= 20 or out_of_stamina == true:
			staminaBarOver.set_tint_progress(Color(1,.17,0))
	
	if stats.hp_precent <= .2 and $PlayerSprite.modulate == Color(1.0,1.0,1.0):
		var _calc = clamp(stats.hp_precent * 5, 0.01, 1)
		make_tween("player",$PlayerSprite,"modulate",Color(1,1,1),Color(1,.3,.3), _calc)
		spriteTween.start()
	
	staminaCircleTween.start()
	staminaBarTween.start()

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/BlendSpace/blend_position", input_vector)
		animationTree.set("parameters/Walk/BlendSpace/blend_position", input_vector)
		animationTree.set("parameters/SwordAttack/BlendSpace/blend_position", input_vector)
		animationTree.set("parameters/Roll/BlendSpace/blend_position", input_vector)
		animationTree.set("parameters/Dash/BlendSpace/blend_position", input_vector)
		print(animationTree.get("parameters/Dash/BlendSpace/blend_position"))
		
		animationState.travel("Walk")
		
		velocity = velocity.move_toward(input_vector * calc_speed, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	if Input.is_action_pressed("sprint") and out_of_stamina == false:
		if input_vector.x != 0 or input_vector.y != 0:
			stamina_cooldown = -200
			stats.set_stamina(stats.stamina - .2)
		sprinting()
	elif out_of_stamina == true:
		speed_modifier = 0.7
	else:
		speed_modifier = 1.0
	
	move()

func roll_state(_delta):
	velocity = roll_vector * calc_speed * 1.4
	if stats.dash:
		roll_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		roll_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		velocity = roll_vector * calc_speed * 1.55
		animationState.travel("Dash")
	else: animationState.travel("Roll")
	move()

func attack_state(_delta):
	velocity = Vector2.ZERO
	animationState.travel("SwordAttack")

func move():
	velocity = move_and_slide(velocity)

func sprinting():
	speed_modifier = 1.4

func no_stamina():
	out_of_stamina = true

func stamina_refilled():
	out_of_stamina = false

func attack_animation_finished():
	state = MOVE

func roll_animation_finished():
	velocity = velocity / 2
	state = MOVE
	$PlayerSprite.self_modulate = Color(1,1,1,1)

func make_tween(tween: String, item, property: String, from, to, time = 0.1):
	if tween == "circle" and staminaCircleTween.is_active() == false:
		staminaCircleTween.interpolate_property(item, property, from, to, .1, Tween.TRANS_LINEAR)
	if tween == "bar" and staminaBarTween.is_active() == false:
		staminaBarTween.interpolate_property(item, property, from, to, .1, Tween.TRANS_LINEAR)
	if tween == "player":
		spriteTween.interpolate_property(item, property, from, to, time, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
		spriteTween.interpolate_property(item, property, to, from, time, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN, time)

func swish_attack():
	var projectile = Projectile.instance()
	
	if stats.health < stats.max_health and stats.health != 1 : return
	
	projectile.get_node("Stats").life_stamp = .8
	projectile.get_node("Stats").max_health = stats.damage + 1
	projectile.get_node("HitBox").damage = stats.damage
	projectile.DEFAULT_SPEED = clamp(275 * attackTimeScale, 20, 700)
	projectile.position = global_position + (roll_vector * 15)
	projectile.direction = roll_vector
	
	if stats.health == 1: 
		projectile.get_node("Sprite").self_modulate = Color(1.0,0.15,0.15) 
		projectile.get_node("Stats").max_health = stats.damage * 5
		projectile.get_node("HitBox").damage = stats.damage * 2
	if stats.health == stats.max_health and stats.temp_health > 0:
		projectile.get_node("Sprite").self_modulate = Color(1.0,1.0,0.15) 
		projectile.get_node("HitBox").damage = stats.damage * 1.3
		projectile.scale = Vector2(1.2,1.2)
	if stats.health == 1 and stats.temp_health > 0:
		projectile.get_node("Sprite").self_modulate = Color(1.2,0.25,0.15) 
		projectile.get_node("Stats").max_health = stats.damage * 5
		projectile.get_node("HitBox").damage = stats.damage * 2.5
		projectile.scale = Vector2(1.4,1.4)
		projectile.get_node("Stats").life_stamp = .75
	MainScene.main.get_node("YSort/Enemies").add_child(projectile)
	projectile = null

func sp_signal(type):
	match type:
		"slow_motion":
			slowmo = true
		"insta_heal":
			stats.set_health(stats.health + stats.max_health)
			slowmo = false
			stats.double_power = false
		"power":
			slowmo = false
			stats.double_power = true
		_, "none":
			slowmo = false
			stats.double_power = false

func no_health():
	die = true
	var slot = 0
	var item
	while slot < 29 and die == true:
		item = Inventories.Main.at_slot(slot)
		if item != null and item.item.attributes.type == "utility":
			if item.item.attributes.utility.revive == true:
				var effect_type = item.item.attributes.utility.effect.type
				var amount: float = item.item.attributes.utility.effect.amount
				match effect_type:
					"add":
						stats.health += amount
					"procent":
						stats.health += stats.max_health * float(amount)
				die = false
			else:
				slot += 1
		else: 
			slot += 1
	if die == true:
		state = NONE
		var _death_effect = MainScene.main.get_node("CanvasLayer/DeathEffect")
		var _tween = MainScene.main.get_node("CanvasLayer/Tween")
		_tween.interpolate_property(_death_effect, "color", Color(0,0,0,0), Color(1,0,0,1), .5, Tween.TRANS_LINEAR)
		_tween.interpolate_property(_death_effect, "color", Color(1,0,0,1), Color(0,0,0,1), .5, Tween.TRANS_LINEAR, 0.8)
		_tween.start()
		hurtBox.get_node("Timer").stop()
		hurtBox.start_invincibility(5.0)
		yield(hurtBox.get_node("Timer"), "timeout")
		Transition.transition()
		yield(Transition,"animation_finished")
		SceneChanger.goto_scene("res://src/maps/GameOver.tscn", MainScene.main)
	else:
		hurtBox.start_invincibility(5.0)
		Inventories.Main.dec_in_slot(slot)

func health_changed(type, amount):
	var text = floating_text.instance()
	text.amount = amount
	text.type = type
	add_child(text)

func set_stamina_bar_style(value):
	match value:
		0:
			staminaCircle.visible = true
			staminaBar.visible = false
		1:
			staminaCircle.visible = false
			staminaBar.visible = true

func count_enemies():
	var count = 0
	var enemies = $CombarChecker.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.state == enemy.CHASE or enemy.state == enemy.SEARCH:
			count += 1
	return count

func in_combat_check():
	var inCombat = false
	var enemies = $CombarChecker.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.state == enemy.CHASE or enemy.state == enemy.SEARCH:
			inCombat = true
			break
	return inCombat

func _on_HurtBox_area_entered(area):
	if area.damage > 0 and die == false:
		stats.deal_damage(clamp(area.damage - stats.defence, 0, area.damage))
		hurtBox.start_invincibility(1.3)
		hurtBox.create_hit_effect()
		var playerHurtSound = PlayerHurtSound.instance()
		self.add_child(playerHurtSound)
		var damage_precent = float(area.damage) / stats.max_health * 100
		if damage_precent <= 5:
			MainScene.main.get_node("Camera2D/ScreenShake").start(.1,55,1,1)
		if damage_precent > 5 and damage_precent <= 20:
			MainScene.main.get_node("Camera2D/ScreenShake").start(.15,75,5,2)
		if damage_precent > 20 and damage_precent <= 50:
			MainScene.main.get_node("Camera2D/ScreenShake").start(.2,95,8,3)
		if damage_precent > 50:
			MainScene.main.get_node("Camera2D/ScreenShake").start(.25,125,12,4)

func _on_HurtBox_invincibility_started():
	flashEffect.play("Flash")

func _on_HurtBox_invincibility_ended():
	flashEffect.play("Stop")

func _on_GhostTimer_timeout():
	if slowmo == true:
		create_ghost()

func create_ghost():
	var ghost = preload("res://src/prefabs/Effects/Ghost.tscn").instance()
	get_parent().add_child(ghost)
	ghost.position.x = position.x
	ghost.position.y = position.y - 9
	ghost.texture = $PlayerSprite.texture
	ghost.vframes = $PlayerSprite.vframes
	ghost.hframes = $PlayerSprite.hframes
	ghost.frame = $PlayerSprite.frame
