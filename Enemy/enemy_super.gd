extends "res://Enemy/enemy.gd"

func death() -> void:
	super.death()
	player.show_result()