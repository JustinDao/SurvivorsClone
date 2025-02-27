extends Area2D

@export var xp: int = 1

var spr_green = preload("res://Textures/Items/Gems/Gem_green.png")
var spr_blue = preload("res://Textures/Items/Gems/Gem_blue.png")
var spr_red = preload("res://Textures/Items/Gems/Gem_red.png")

var target: Node2D = null
var speed = -1

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var snd_collect = $snd_collect

func _ready() -> void:
	if xp > 25:
		sprite.texture = spr_red
	elif xp > 10:
		sprite.texture = spr_blue
	else:
		sprite.texture = spr_green

func _physics_process(delta: float) -> void:
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2 * delta
		
func collect() -> int:
	snd_collect.play()
	collision.call_deferred("set", "disabled", true)
	sprite.visible = false
	return xp


func _on_snd_collect_finished() -> void:
	queue_free()
