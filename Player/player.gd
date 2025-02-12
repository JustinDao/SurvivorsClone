extends CharacterBody2D

var movement_speed: float = 80.0
var hp: float = 80.0

# Attacks
var ice_spear = preload("res://Player/Attack/ice_spear.tscn")

# AttackNodes
@onready var ice_spear_timer = $Attack/IceSpearTimer
@onready var ice_spear_attack_timer = $Attack/IceSpearTimer/IceSpearAttackTimer

# IceSpear
var ice_spear_ammo = 0
var ice_spear_base_ammo = 1
var ice_spear_attack_speed = 1.5
var ice_spear_level = 1

# Enemies
var enemy_close = []

@onready var sprite: Sprite2D = $Sprite2D
@onready var walkTimer: Timer = get_node("WalkTimer")

func _ready() -> void:
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
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else:
				sprite.frame += 1
			walkTimer.start()
	
	velocity = mov.normalized() * movement_speed
	move_and_slide()
	pass


func _on_hurt_box_hurt(damage: float) -> void:
	hp -= damage

func attack() -> void:
	if ice_spear_level > 0:
		ice_spear_timer.wait_time = ice_spear_attack_speed
		if ice_spear_timer.is_stopped():
			ice_spear_timer.start()

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
