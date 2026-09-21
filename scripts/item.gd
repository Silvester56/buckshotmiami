extends ClickableEntity

var type

var configuration = [
	{ "type": Global.ItemType.KNIFE, "reRollChance": null, "frame": 0, "name": "Knife", "description": "Shotgun deals 2 damage."},
	{ "type": Global.ItemType.HANDCUFFS, "reRollChance": 50, "frame": 1, "name": "Handcuffs", "description": "Dealer skips the next turn."},
	{ "type": Global.ItemType.LENS, "reRollChance": 50, "frame": 2, "name": "Magnifying glass", "description": "Check the current round in the chamber."},
	{ "type": Global.ItemType.BEER, "reRollChance": null, "frame": 3, "name": "Beer", "description": "Racks the shotgun. Ejects current shell."},
	{ "type": Global.ItemType.INVERTER, "reRollChance": 70, "frame": 4, "name": "Inverter", "description": "Swaps the polarity of the current shell in the chamber."},
	{ "type": Global.ItemType.CIGS, "reRollChance": null, "frame": 5, "name": "Cigarette pack", "description": "Takes the edge off. Regain 1 heart."},
]

func isItemType(obj, expected) -> bool:
	return obj.type == expected

func getStatus() -> Dictionary:
	return {
		"type": type,
		"isActive": isActive,
	}

func setProperties(imposedType, posX, posY) -> void:
	var config
	isActive = true
	if imposedType == null:
		config = configuration.pick_random()
		if config.reRollChance and randi() % 100 < config.reRollChance:
			config = configuration.pick_random()
	else:
		config = configuration[configuration.find_custom(isItemType.bind(imposedType))]
	type = config.type
	frame = config.frame
	title = config.name
	description = config.description
	position.x = posX
	position.y = posY

func actionOnClick() -> void:
	emit_signal("click", type)
	queue_free()
