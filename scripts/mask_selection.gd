extends Control

@export var MaskButton: PackedScene

var listOfMasks = [
	{ "id": 0, "label": "Richard", "key": null, "value": null },
	{ "id": 1, "label": "Rasmus", "key": "itemStart", "value": Global.ItemType.LENS },
	{ "id": 2, "label": "Tony", "key": "itemStart", "value": Global.ItemType.BEER },
	{ "id": 3, "label": "Aubrey", "key": "shotgunBaseDamage", "value": 2 },
]

func checkMaskId(mask, expected) -> bool:
	return mask.id == expected

func _ready() -> void:
	var newPositionY = 0;
	for mask in listOfMasks:
		var maskButton = MaskButton.instantiate()
		newPositionY = newPositionY + 100
		maskButton.setProperties(mask.id, mask.label, newPositionY)
		maskButton.click.connect(_on_mask_button_pressed)
		add_child(maskButton)

func _on_mask_button_pressed(id) -> void:
	Global.setMask(listOfMasks[listOfMasks.find_custom(checkMaskId.bind(id))])
	get_tree().change_scene_to_file("res://scenes/game.tscn")
