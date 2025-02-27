extends Area2D

var level: int = 1
var hp: int = 1
var speed = 120.0
var damage = 5
var knockback_amount: int = 100
var attack_size: float = 1.0

var target: Vector2 = Vector2.ZERO
var angle: Vector2 = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")

signal on_queue_free(object: Node2D)

func _ready() -> void:
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)

	# Default values
	hp = 1
	speed = 100.0
	damage = 5
	knockback_amount = 100
	attack_size = 1.0 * (1 + player.spell_size)

	match level:
		1:
			pass
		2:
			pass
		3:
			hp = 2
			damage = 8
		4:
			pass
			
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1) * attack_size, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
		
func _physics_process(delta: float) -> void:
	position += angle * speed * delta

func enemy_hit(charge: int = 1):
	hp -= charge
	if hp <= 0:
		on_queue_free.emit(self)
		queue_free()

func _on_timer_timeout() -> void:
	on_queue_free.emit(self)
	queue_free()
