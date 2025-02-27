extends ColorRect

@onready var name_label: Label = $NameLabel
@onready var description_label: Label = $DescriptionLabel
@onready var level_label: Label = $LevelLabel
@onready var icon: TextureRect = $ColorRect/ItemIcon

var mouse_over: bool = false
var item = null
@onready var player = get_tree().get_first_node_in_group("player")

signal selected_upgrade(upgrade)

func _ready() -> void:
	selected_upgrade.connect(Callable(player, "upgrade_character"))

	# Set Item Option information
	if item == null:
		item = "food"
	var upgrade = Upgrades.UPGRADES[item]
	name_label.text = upgrade["display_name"]
	description_label.text = upgrade["description"]
	if upgrade["level"] > 0:
		level_label.text = "Level " + str(upgrade["level"])
	else:
		level_label.text = ""
	icon.texture = load(upgrade["icon"])

func _input(event: InputEvent) -> void:
	if event.is_action("click"):
		if mouse_over:
			selected_upgrade.emit(item)

func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false
