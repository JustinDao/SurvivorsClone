extends Area2D

@export var damage: float = 1.0

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var disableTimer: Timer = $DisableHitBoxTimer

func temp_disable() -> void:
	collision.call_deferred("set", "disabled", true)
	disableTimer.start()

func _on_disable_hit_box_timer_timeout() -> void:
	collision.call_deferred("set", "disabled", false)
