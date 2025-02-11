extends CharacterBody2D

@export var movement_speed: float = 40.0
@export var hp: float = 10.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation: AnimationPlayer = $AnimationPlayer

@onready var player: Node = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	animation.play("walk")

func _physics_process(_delta: float) -> void:
	var direction_normalized: Vector2 = global_position.direction_to(player.global_position)
	velocity = direction_normalized * movement_speed

	if direction_normalized.x > 0:
		sprite.flip_h = true
	elif direction_normalized.x < 0:
		sprite.flip_h = false

	move_and_slide()


func _on_hurt_box_hurt(damage: float) -> void:
	hp -= damage
	if hp <= 0:
		queue_free()
