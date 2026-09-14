extends ClickableEntity

var type

var configuration = [
	{ "type": Global.ItemType.KNIFE, "frame": 0, "name": "Knife", "description": "Shotgun deals 2 damage."},
	{ "type": Global.ItemType.HANDCUFFS, "frame": 1, "name": "Handcuffs", "description": "Dealer skips the next turn."},
	{ "type": Global.ItemType.GLASS, "frame": 2, "name": "Magnifying glass", "description": "Check the current round in the chamber."},
	{ "type": Global.ItemType.BEER, "frame": 3, "name": "Beer", "description": "Racks the shotgun. Ejects current shell."},
	{ "type": Global.ItemType.INVERTER, "frame": 4, "name": "Inverter", "description": "Swaps the polarity of the current shell in the chamber."},
	{ "type": Global.ItemType.CIGS, "frame": 5, "name": "Cigarette pack", "description": "Takes the edge off. Regain 1 heart."},
]

func isItemType(obj, expected) -> bool:
	return obj.type == expected

func setProperties(imposedType, posX, posY) -> void:
	var config
	isActive = true
	if imposedType == null:
		config = configuration.pick_random()
	else:
		config = configuration.find_custom(isItemType.bind(imposedType))
	type = config.type
	frame = config.frame
	title = config.name
	description = config.description
	position.x = posX
	position.y = posY
