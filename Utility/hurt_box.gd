extends Area2D

enum HurtBoxType {COOLDOWN, HIT_ONCE, DISABLE_HIT_BOX}
@export var hurtBoxType = HurtBoxType.COOLDOWN

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var disableTimer: Timer = $DisableTimer

signal hurt(damage: float)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group('attack'):
		if area.get("damage") != null:
			match hurtBoxType:
				HurtBoxType.COOLDOWN:
					collision.call_deferred("set", "disabled", true)
					disableTimer.start()
				HurtBoxType.HIT_ONCE:
					pass
				HurtBoxType.DISABLE_HIT_BOX:
					if area.has_method("temp_disable"):
						area.temp_disable()
			var damage = area.damage
			hurt.emit(damage)
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)


func _on_disable_timer_timeout() -> void:
	collision.call_deferred("set", "disabled", false)
