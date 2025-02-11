extends CharacterBody2D

var movement_speed: float = 80.0
var hp: float = 80.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var walkTimer: Timer = get_node("WalkTimer")

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
