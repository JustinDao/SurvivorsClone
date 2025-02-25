extends Area2D

var level: int = 1
var hp: int = 9999
var speed = 100.0
var damage = 5
var knockback_amount: int = 100
var attack_size: float = 1.0

var last_movement: Vector2 = Vector2.ZERO
var angle: Vector2 = Vector2.ZERO
var angle_less: Vector2 = Vector2.ZERO
var angle_more: Vector2 = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")

signal on_queue_free(object: Node2D)

func _ready() -> void:
	match level:
		1:
			hp = 9999
			speed = 20.0
			damage = 5
			knockback_amount = 100
			attack_size = 1.0

	var move_to_less = Vector2.ZERO
	var move_to_more = Vector2.ZERO
	match last_movement:
		Vector2.UP, Vector2.DOWN:
			move_to_less = global_position + Vector2(randf_range(-1, -0.25), last_movement.y) * 500
			move_to_more = global_position + Vector2(randf_range(0.25, 1), last_movement.y) * 500
		Vector2.LEFT, Vector2.RIGHT:
			move_to_less = global_position + Vector2(last_movement.x, randf_range(-1, -0.25)) * 500
			move_to_more = global_position + Vector2(last_movement.x, randf_range(0.25, 1)) * 500
		Vector2(1, 1), Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1):
			move_to_less = global_position + Vector2(last_movement.x, last_movement.y * randf_range(0, 0.75)) * 500
			move_to_more = global_position + Vector2(last_movement.x * randf_range(0, 0.75), last_movement.y) * 500
	
	angle_less = global_position.direction_to(move_to_less)
	angle_more = global_position.direction_to(move_to_more)

	var initial_tween = create_tween().set_parallel(true)
	initial_tween.tween_property(self, "scale", Vector2(1, 1) * attack_size, 3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	var final_speed = speed * 5
	initial_tween.tween_property(self, "speed", final_speed, 6).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	initial_tween.play()
	
	var tween = create_tween()
	var set_angle = randf_range(0, 1)
	if set_angle == 1:
		angle = angle_less
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.set_loops()
	else:
		angle = angle_more
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.set_loops()
	tween.play()
		
	
func _physics_process(delta: float) -> void:
	position += angle * speed * delta

func _on_timer_timeout() -> void:
	on_queue_free.emit(self)
	queue_free()
