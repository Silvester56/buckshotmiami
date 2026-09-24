extends ClickableEntity

var maskCongig

var configuration = [
	{ "id": 0, "name": "Richard", "description": "", "key": null, "value": null },
	{ "id": 1, "name": "Rasmus", "description": "An eye for secrets", "key": "itemStart", "value": Global.ItemType.LENS },
	{ "id": 2, "name": "Tony", "description": "Thirst of fury", "key": "itemStart", "value": Global.ItemType.BEER },
	{ "id": 3, "name": "Aubrey", "description": "More damage", "key": "shotgunBaseDamage", "value": 2 },
]

func isMaskId(mask, expected) -> bool:
	return mask.id == expected

func setProperties(i, posX, posY) -> void:
	maskCongig = configuration[configuration.find_custom(isMaskId.bind(i))]
	frame = 4 + i
	position.x = posX
	position.y = posY
	title = maskCongig.name
	description = maskCongig.description
	setIsActive(true)

func actionOnClick() -> void:
	Global.setMask(maskCongig)
	get_tree().change_scene_to_file("res://scenes/game.tscn")
