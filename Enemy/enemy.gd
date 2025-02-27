extends CharacterBody2D

@export var movement_speed: float = 40.0
@export var hp: float = 10.0
@export var knockback_recovery: float = 3.5
@export var xp: int = 1
var knockback: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var snd_hit: AudioStreamPlayer2D = $snd_hit

@onready var player: Node = get_tree().get_first_node_in_group("player")
var death_animation = preload("res://Enemy/explosion.tscn")

@onready var loot_group: Node2D = get_tree().get_first_node_in_group("loot")
var exp_gem = preload("res://Objects/experience_gem.tscn")

signal on_queue_free(object: Node2D)

func _ready() -> void:
	animation.play("walk")

func _physics_process(_delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	var direction_normalized: Vector2 = global_position.direction_to(player.global_position)
	velocity = direction_normalized * movement_speed
	velocity += knockback

	if direction_normalized.x > 0:
		sprite.flip_h = true
	elif direction_normalized.x < 0:
		sprite.flip_h = false

	move_and_slide()

func death() -> void:
	on_queue_free.emit(self)
	var enemy_death = death_animation.instantiate()
	enemy_death.scale = scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.xp = xp
	loot_group.call_deferred("add_child", new_gem)
	queue_free()

func _on_hurt_box_hurt(damage: float, angle: Vector2, knockback_amount: float) -> void:
	hp -= damage
	if hp <= 0:
		death()
	else:
		snd_hit.play()
		knockback = angle * knockback_amount
