extends TextureRect

@onready var item_texture: TextureRect = $ItemTexture
var item = null

func _ready() -> void:
	if item != null:
		item_texture.texture = load(Upgrades.UPGRADES[item]["icon"])
