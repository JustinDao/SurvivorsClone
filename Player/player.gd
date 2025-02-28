extends CharacterBody2D

var elapsed_time_seconds: float = 0.0

var movement_speed: float = 80.0
var hp: float = 80.0
var max_hp: float = 80.0
var last_movement: Vector2 = Vector2.UP

var xp = 0
var level = 1
var xp_for_next_level = 0
var remaining_xp = 0

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
var ice_spear_base_ammo = 0
var ice_spear_attack_speed = 0
var ice_spear_level = 0

# Tornado
var tornado_ammo = 0
var tornado_base_ammo = 0
var tornado_attack_speed = 0
var tornado_level = 0

# Javelin
var javelin_ammo = 0
var javelin_level = 0

# Enemies
var enemy_close = []

@onready var sprite: Sprite2D = $Sprite2D
@onready var walkTimer: Timer = get_node("WalkTimer")

# GUI
@onready var xp_bar: TextureProgressBar = $GUILayer/GUI/XpBar
@onready var level_label: Label = $GUILayer/GUI/XpBar/LevelLabel
@onready var health_bar: TextureProgressBar = $GUILayer/GUI/HealthBar
@onready var timer_label: Label = $GUILayer/GUI/TimerLabel
@onready var collected_weapons: GridContainer = $GUILayer/GUI/CollectedWeapons
@onready var collected_upgrades: GridContainer = $GUILayer/GUI/CollectedUpgrades
var item_container = preload("res://Player/GUI/item_container.tscn")

@onready var level_up_panel: Panel = $GUILayer/GUI/LevelUp
@onready var level_up_label: Label = $GUILayer/GUI/LevelUp/LevelUpLabel
@onready var upgrade_options: VBoxContainer = $GUILayer/GUI/LevelUp/UpgradeOptions
@onready var snd_level_up: AudioStreamPlayer2D = $GUILayer/GUI/LevelUp/snd_level_up
var item_option = preload("res://Utility/item_option.tscn")

@onready var result_panel: Panel = $GUILayer/GUI/ResultPanel
@onready var result_label: Label = $GUILayer/GUI/ResultPanel/ResultLabel
@onready var snd_win: AudioStreamPlayer2D = $GUILayer/GUI/ResultPanel/snd_win
@onready var snd_lose: AudioStreamPlayer2D = $GUILayer/GUI/ResultPanel/snd_lose
@onready var menu_button: Button = $GUILayer/GUI/ResultPanel/MenuBasicButton

signal player_death()

# Upgrades
var collected_items: Array[String] = []
var collected_display_names: Array[String] = []
var armor = 0
var speed = 0
var spell_cooldown = 0
var spell_size = 0
var additional_attacks = 0

func _ready() -> void:
	health_bar.value = hp
	health_bar.max_value = max_hp
	xp_for_next_level = get_xp_for_next_level()
	upgrade_character("icespear1")
	
func _physics_process(delta: float) -> void:
	movement()
	update_time(delta)

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


func _on_hurt_box_hurt(damage: float, _angle: Vector2, _knockback: float) -> void:
	hp -= clamp(damage - armor, 0, damage)
	health_bar.value = hp
	if hp <= 0:
		# Player is dead
		show_result()
		player_death.emit()
		
func show_result() -> void:
	result_panel.show()
	get_tree().paused = true
	# Animate Result Panel In
	var tween = result_panel.create_tween()
	tween.tween_property(result_panel, "position", Vector2(220, 50), 3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	# Don't need to kill the final boss to win
	if elapsed_time_seconds >= 300:
		result_label.text = "You Win!"
		snd_win.play()
	else:
		result_label.text = "You Lose!"
		snd_lose.play()
		
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
func update_attacks() -> void:
	if ice_spear_level > 0:
		ice_spear_timer.wait_time = ice_spear_attack_speed * (1 - spell_cooldown)
		if ice_spear_timer.is_stopped():
			ice_spear_timer.start()
	
	if tornado_level > 0:
		tornado_timer.wait_time = tornado_attack_speed * (1 - spell_cooldown)
		if tornado_timer.is_stopped():
			tornado_timer.start()

	if javelin_level > 0:
		spawn_javelin()

# IceSpear Timers
func _on_ice_spear_timer_timeout() -> void:
	ice_spear_ammo += ice_spear_base_ammo + additional_attacks
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
	tornado_ammo += tornado_base_ammo + additional_attacks
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
	var calc_spawns = javelin_ammo - javelin_count + additional_attacks
	for count in range(calc_spawns):
		var new_javelin = javelin.instantiate()
		new_javelin.global_position = global_position
		javelin_base.add_child(new_javelin)
	# update javelins
	for child in javelin_base.get_children():
		if child.has_method("update_javelin"):
			child.update_javelin()
	

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

		remaining_xp = xp - xp_for_next_level
		xp = 0
		level_up()
	
	level_label.text = "Level: " + str(level)
	xp_bar.value = (float(xp) / xp_for_next_level * 100)
	
func get_xp_for_next_level() -> int:
	if level < 20:
		return level * 5
	elif level < 40:
		return 95 + (level - 19) * 8
	else:
		return 255 + (level - 39) * 12

# Level Up
func level_up() -> void:
	snd_level_up.play()
	# Set Level Up Label
	level_up_label.text = "Level " + str(level)
	# Show Level Up Panel
	level_up_panel.show()
	
	# Instantiate Options
	var upgrades = get_random_upgrades()
	for i in range(upgrades.size()):
		var new_option = item_option.instantiate()
		new_option.item = upgrades[i]
		upgrade_options.add_child(new_option)

	# Animate Level Up Panel In
	var levelTween = level_up_panel.create_tween()
	levelTween.tween_property(level_up_panel, "position", Vector2(220, 50), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	levelTween.play()
	# Pause Game
	get_tree().paused = true

func upgrade_character(item: String) -> void:
	for option in upgrade_options.get_children():
		option.queue_free()
	# Apply Upgrade
	apply_upgrade(item)
	update_attacks()
	# Add Item to Collected Items if not Food
	if item != "food":
		collected_items.append(item)
		update_item_gui(item)
	# Hide Level Panel
	level_up_panel.hide()
	level_up_panel.position = Vector2(800, 50)
	# Resume Game
	get_tree().paused = false
	if remaining_xp > 0:
			calculate_experience(remaining_xp)

func get_all_available_upgrades() -> Array[String]:
	var all_choices: Array[String] = []
	for item in Upgrades.UPGRADES:
		var upgrade = Upgrades.UPGRADES[item]
		if !collected_items.has(item) && \
		   upgrade["type"] != "item" && \
		   upgrade["prerequisites"].all(collected_items.has):
			all_choices.append(item)
	return all_choices

func get_random_upgrades() -> Array[String]:
	var all_choices = get_all_available_upgrades()

	# Add up to 3 random upgrades
	all_choices.shuffle()
	var choices: Array[String] = []
	for i in range(3):
		if all_choices.size() > 0:
			var choice = all_choices.pop_front()
			choices.append(choice)
		else:
			break

	# If no upgrades are available, return food
	if choices.size() == 0:
		return ["food"]

	return choices

func apply_upgrade(item: String) -> void:
	match item:
		"icespear1":
			ice_spear_level = 1
			ice_spear_base_ammo += 1
		"icespear2":
			ice_spear_level = 2
			ice_spear_base_ammo += 1
		"icespear3":
			ice_spear_level = 3
		"icespear4":
			ice_spear_level = 4
			ice_spear_base_ammo += 2
		"tornado1":
			tornado_level = 1
			tornado_base_ammo += 1
		"tornado2":
			tornado_level = 2
			tornado_base_ammo += 1
		"tornado3":
			tornado_level = 3
			tornado_attack_speed -= 0.5
		"tornado4":
			tornado_level = 4
			tornado_base_ammo += 1
		"javelin1":
			javelin_level = 1
			javelin_ammo = 1
		"javelin2":
			javelin_level = 2
		"javelin3":
			javelin_level = 3
		"javelin4":
			javelin_level = 4
		"armor1", "armor2", "armor3", "armor4":
			armor += 1
		"speed1", "speed2", "speed3", "speed4":
			movement_speed += 20.0
		"tome1", "tome2", "tome3", "tome4":
			spell_size += 0.10
		"scroll1", "scroll2", "scroll3", "scroll4":
			spell_cooldown += 0.05
		"ring1", "ring2":
			additional_attacks += 1
		"food":
			hp += 20
			hp = clamp(hp, 0, max_hp)

func update_time(delta: float) -> void:
	elapsed_time_seconds += delta
	var minutes = int(elapsed_time_seconds / 60)
	var seconds = int(elapsed_time_seconds) % 60

	var minute_text = str(minutes) if minutes > 9 else "0" + str(minutes)
	var second_text = str(seconds) if seconds > 9 else "0" + str(seconds)
	timer_label.text = minute_text + ":" + second_text

func update_item_gui(item: String) -> void:
	var upgrade = Upgrades.UPGRADES[item]
	var type = upgrade["type"]
	var display_name = upgrade["display_name"]

	if type == "item":
		return

	if collected_display_names.has(display_name):
		return
	
	collected_display_names.append(display_name)
	var new_item_container = item_container.instantiate()
	new_item_container.item = item
	match type:
		"weapon":
			collected_weapons.add_child(new_item_container)
		"upgrade":
			collected_upgrades.add_child(new_item_container)

func _on_menu_basic_button_click_end() -> void:
	get_tree().paused = false
	var _level = get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")
