extends Button

@onready var snd_hover: AudioStreamPlayer2D = $snd_hover
@onready var snd_click: AudioStreamPlayer2D = $snd_click

signal click_end()

func _on_mouse_entered() -> void:
	snd_hover.play()


func _on_pressed() -> void:
	snd_click.play()

func _on_snd_click_finished() -> void:
	click_end.emit()
