extends Area2D

var level: int = 1
var hp: int = 1
var speed = 120.0
var damage = 10
var knockback_amount: int = 200
var attack_size: float = 1.0

var paths = 1
var attack_speed = 4.0

var target = Vector2.ZERO
var target_array = []

var angle: Vector2 = Vector2.ZERO
var reset_pos: Vector2 = Vector2.ZERO

var spr_jav_reg = preload("res://Textures/Items/Weapons/javelin_3_new.png")
var spr_jav_attack = preload("res://Textures/Items/Weapons/javelin_3_new_attack.png")

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var attack_timer = $AttackTimer
@onready var change_direction_timer = $ChangeDirectionTimer
@onready var reset_pos_timer = $ResetPosTimer
@onready var snd_attack = $snd_attack

signal on_queue_free(object: Node2D)

func _ready() -> void:
	update_javelin()

func update_javelin() -> void:
	level = player.javelin_level

	# Default values
	hp = 9999
	speed = 200.0
	damage = 10
	knockback_amount = 100
	attack_size = 1.0 * (1 + player.spell_size)
	paths = 1
	attack_speed = 5.0 * (1 - player.spell_cooldown)

	match level:
		1:
			pass
		2:
			paths = 2
		3:
			paths = 3
		4:
			damage = 15
			knockback_amount = 120
	
	scale = Vector2(1, 1) * attack_size
	attack_timer.wait_time = attack_speed

func _physics_process(delta: float) -> void:
	if target_array.size() > 0:
		position += angle * speed * delta
	else:
		var player_angle = global_position.direction_to(reset_pos)
		var distance_diff = global_position - player.global_position
		var return_speed = 20
		if abs(distance_diff.x) > 500 || abs(distance_diff.y) > 500:
			return_speed = 100
		position += player_angle * return_speed * delta
		rotation = global_position.direction_to(player.global_position).angle() + deg_to_rad(135)

func _on_attack_timer_timeout() -> void:
	add_paths()

func on_attack() -> void:
	snd_attack.play()
	on_queue_free.emit(self)

func add_paths() -> void:
	on_attack()
	target_array.clear()
	for count in range(paths):
		var new_path = player.get_random_target()
		target_array.append(new_path)
		enable_attack(true)
	target = target_array[0]
	process_path()

func process_path() -> void:
	angle = global_position.direction_to(target)
	change_direction_timer.start()
	var tween = create_tween()
	var new_rotation_deg = angle.angle() + deg_to_rad(135)
	tween.tween_property(self, "rotation", new_rotation_deg, 0.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	
func _on_change_direction_timer_timeout() -> void:
	if target_array.size() > 0:
		target_array.remove_at(0)
		if target_array.size() > 0:
			target = target_array[0]
			process_path()
			on_attack()
		else:
			enable_attack(false)
	else:
		change_direction_timer.stop()
		attack_timer.start()
		enable_attack(false)

func enable_attack(enabled: bool) -> void:
	if enabled:
		collision.call_deferred("set", "disabled", false)
		sprite.texture = spr_jav_attack
	else:
		collision.call_deferred("set", "disabled", true)
		sprite.texture = spr_jav_reg


func _on_reset_pos_timer_timeout() -> void:
	var choose_direction = randi() % 4
	reset_pos = player.global_position
	match choose_direction:
		0:
			reset_pos.x += 50
		1:
			reset_pos.x -= 50
		2:
			reset_pos.y += 50
		3:
			reset_pos.y -= 50
