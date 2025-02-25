extends Area2D

enum HurtBoxType {COOLDOWN, HIT_ONCE, DISABLE_HIT_BOX}
@export var hurtBoxType = HurtBoxType.COOLDOWN

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var disableTimer: Timer = $DisableTimer

signal hurt(damage: float, angle: Vector2, knockback: float)

var hit_once_array = []

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group('attack'):
		if area.get("damage") != null:
			match hurtBoxType:
				HurtBoxType.COOLDOWN:
					collision.call_deferred("set", "disabled", true)
					disableTimer.start()
				HurtBoxType.HIT_ONCE:
					if !hit_once_array.has(area):
						hit_once_array.append(area)
						if !area.is_connected("on_queue_free", Callable(self, "remove_from_list")):
							area.connect("on_queue_free", Callable(self, "remove_from_list"))
					else:
						return
				HurtBoxType.DISABLE_HIT_BOX:
					if area.has_method("temp_disable"):
						area.temp_disable()
			var damage = area.damage

			var angle = Vector2.ZERO
			var knockback = 1
			if area.get("angle") != null:
				angle = area.angle
			if area.get("knockback_amount") != null:
				knockback = area.knockback_amount

			hurt.emit(damage, angle, knockback)

			if area.has_method("enemy_hit"):
				area.enemy_hit(1)

func remove_from_list(node: Node2D) -> void:
	if hit_once_array.has(node):
		hit_once_array.erase(node)

func _on_disable_timer_timeout() -> void:
	collision.call_deferred("set", "disabled", false)
