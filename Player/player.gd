extends CharacterBody2D

var movement_speed: float = 80.0
var hp: float = 80.0
var last_movement: Vector2 = Vector2.UP

var xp = 0
var level = 1
var xp_for_next_level = 0

# Attacks
var ice_spear = preload("res://Player/Attack/ice_spear.tscn")
var tornado = preload("res://Player/Attack/tornado.tscn")
var javelin = preload("res://Player/Attack/javelin.tscn")

# AttackNodes
@onready var ice_spear_timer = $Attack/IceSpearTimer
@onready var ice_spear_attack_timer = $Attack/IceSpearTimer/IceSpearAttackTimer
@onready var tornado_timer = $Attack/TornadoTimer
@onready var tornado_attack_timer = $Attack/TornadoTimer/TornadoAttackTimer
@onready var javelin_base = $Attack/JavelinBase

# IceSpear
var ice_spear_ammo = 0
var ice_spear_base_ammo = 1
var ice_spear_attack_speed = 1.5
var ice_spear_level = 0

# Tornado
var tornado_ammo = 0
var tornado_base_ammo = 3
var tornado_attack_speed = 3
var tornado_level = 0

# Javelin
var javelin_ammo = 1
var javelin_level = 1

# Enemies
var enemy_close = []

@onready var sprite: Sprite2D = $Sprite2D
@onready var walkTimer: Timer = get_node("WalkTimer")

# GUI
@onready var xp_bar: TextureProgressBar = $GUILayer/GUI/XpBar
@onready var level_label: Label = $GUILayer/GUI/XpBar/LevelLabel

func _ready() -> void:
	xp_for_next_level = get_xp_for_next_level()
	attack()

func _physics_process(_delta: float) -> void:
	movement()

func movement() -> void:
	var x_mov: float = Input.get_action_strength('right') - Input.get_action_strength('left')
	var y_mov: float = Input.get_action_strength('down') - Input.get_action_strength('up')
	var mov: Vector2 = Vector2(x_mov, y_mov)

	if mov.x > 0:
		sprite.flip_h = true
	elif mov.x < 0:
		sprite.flip_h = false

	if mov != Vector2.ZERO:
		last_movement = mov
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else:
				sprite.frame += 1
			walkTimer.start()
	
	velocity = mov.normalized() * movement_speed
	move_and_slide()
	pass


func _on_hurt_box_hurt(damage: float, _angle: Vector2, _knockback: float) -> void:
	hp -= damage

func get_random_target() -> Vector2:
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position

	return Vector2.UP

func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	if !enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	if enemy_close.has(body):
		enemy_close.erase(body)


# Attacks
func attack() -> void:
	if ice_spear_level > 0:
		ice_spear_timer.wait_time = ice_spear_attack_speed
		if ice_spear_timer.is_stopped():
			ice_spear_timer.start()
	
	if tornado_level > 0:
		tornado_timer.wait_time = tornado_attack_speed
		if tornado_timer.is_stopped():
			tornado_timer.start()

	if javelin_level > 0:
		spawn_javelin()

# IceSpear Timers
func _on_ice_spear_timer_timeout() -> void:
	ice_spear_ammo += ice_spear_base_ammo
	ice_spear_attack_timer.start()

func _on_ice_spear_attack_timer_timeout() -> void:
	if ice_spear_ammo > 0:
		var new_ice_spear = ice_spear.instantiate()
		new_ice_spear.position = position
		new_ice_spear.target = get_random_target()
		new_ice_spear.level = ice_spear_level
		add_child(new_ice_spear)
		ice_spear_ammo -= 1
		if ice_spear_ammo > 0:
			ice_spear_attack_timer.start()
		else:
			ice_spear_attack_timer.stop()

# Tornado Timers
func _on_tornado_timer_timeout() -> void:
	tornado_ammo += tornado_base_ammo
	tornado_attack_timer.start()

func _on_tornado_attack_timer_timeout() -> void:
	if tornado_ammo > 0:
		var new_tornado = tornado.instantiate()
		new_tornado.position = position
		new_tornado.last_movement = last_movement
		new_tornado.level = tornado_level
		add_child(new_tornado)
		tornado_ammo -= 1
		if tornado_ammo > 0:
			tornado_attack_timer.start()
		else:
			tornado_attack_timer.stop()

# Javelin
func spawn_javelin() -> void:
	var javelin_count = javelin_base.get_child_count()
	var calc_spawns = javelin_ammo - javelin_count
	for count in range(calc_spawns):
		var new_javelin = javelin.instantiate()
		new_javelin.global_position = global_position
		javelin_base.add_child(new_javelin)


func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		area.target = self


func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var added_xp = area.collect()
		calculate_experience(added_xp)

func calculate_experience(added_xp: int) -> void:
	xp += added_xp

	if xp >= xp_for_next_level:
		level += 1
		xp_for_next_level = get_xp_for_next_level()

		var remaining = xp - xp_for_next_level
		xp = 0

		if remaining > 0:
			calculate_experience(remaining)
	
	level_label.text = "Level: " + str(level)
	xp_bar.value = (float(xp) / xp_for_next_level * 100)
	
func get_xp_for_next_level() -> int:
	if level < 20:
		return level * 5
	elif level < 40:
		return 95 + (level - 19) * 8
	else:
		return 255 + (level - 39) * 12
