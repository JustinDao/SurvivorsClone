extends Control

var world = "res://World/world.tscn"

func _on_play_button_click_end() -> void:
	get_tree().change_scene_to_file(world)

func _on_exit_button_click_end() -> void:
	get_tree().quit()
