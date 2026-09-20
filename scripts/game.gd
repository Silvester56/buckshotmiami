extends Node2D

@export var Shell: PackedScene
@export var Character: PackedScene
@export var Item: PackedScene
@export var Dialog: PackedScene

var dealer
var player
var dialog
var shells = []
var gameSpeed: float
var gameDelay: float
var lastMouseMode
const roundsConfiguration = [
	{ "id": 0, "health": 2, "min": 2, "max": 4, "items": 0 },
	{ "id": 1, "health": 4, "min": 3, "max": 6, "items": 2 },
	{ "id": 2, "health": 6, "min": 4, "max": 8, "items": 4 },
]
var currentRound = 0
var shotgun
var shotgunRotation: float = 0
var shotgunTarget: float = 0
var shotgunBaseDamage: int = 1
var shotgunDamage: int = shotgunBaseDamage
var isPlayerTurn: bool = false
var isPlayerTurnBlocked: bool = false
var isDealerTurnBlocked: bool = false
var playerItemSlots
var dealerItemSlots
var nextShellKnowledge = false

func _ready() -> void:
	changeMouseDisplay(Global.MouseOption.CAPTURED)
	var roundObject = roundsConfiguration[currentRound]
	var distanceFromBorder = 50
	gameSpeed = 1
	gameDelay = 3 / gameSpeed
	player = Character.instantiate()
	player.setProperties(true, roundObject.health, 256, 512 - distanceFromBorder)
	player.character_click.connect(_on_character_click)
	dealer = Character.instantiate()
	dealer.setProperties(false, roundObject.health, 256, distanceFromBorder)
	dealer.character_click.connect(_on_character_click)
	dialog = Dialog.instantiate()
	dialog.setProperties(256, 384, 1 / gameSpeed)
	$Background.add_sibling(player)
	$Background.add_sibling(dealer)
	$Background.add_sibling(dialog)
	playerItemSlots = getItemSlotsConfiguration(64, 386, 64, 8)
	dealerItemSlots = getItemSlotsConfiguration(64, 64, 64, 8)
	initRound()

func _process(delta: float) -> void:
	if shotgunRotation < shotgunTarget:
		shotgunRotation = shotgunRotation + gameSpeed
	if shotgunRotation > shotgunTarget:
		shotgunRotation = shotgunRotation - gameSpeed
	$Shotgun.rotation = deg_to_rad(shotgunRotation)
	if Input.is_action_just_pressed("pause") and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		$PauseMenu.show()
		get_tree().paused = true
		changeMouseDisplay(Global.MouseOption.VISIBLE)

func changeMouseDisplay(option: Global.MouseOption) -> void:
	if option == Global.MouseOption.VISIBLE:
		lastMouseMode = Input.get_mouse_mode()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif option == Global.MouseOption.CAPTURED:
		lastMouseMode = Input.get_mouse_mode()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(lastMouseMode)

func getItemSlotsConfiguration(startX, startY, item_gap, number) -> Array:
	var result = []
	var newPosX = 0
	var newGroupX = 0
	for index in number:
		if (index / 2) % 2 == 0:
			newGroupX = startX
		else:
			newGroupX = 512 - startX - item_gap
		newPosX = newGroupX + (index % 2) * item_gap
		result.push_back({"item": null, "posX": newPosX, "posY": startY + (index / 4 * item_gap) })
	return result

func tryPlacingNewItem(imposedType, isPlayer) -> bool:
	var item
	var itemSlots = dealerItemSlots
	if isPlayer:
		itemSlots = playerItemSlots
	for itemIndex in len(itemSlots):
		if itemSlots[itemIndex].item:
			pass
		else:
			item = Item.instantiate()
			item.setProperties(null, itemSlots[itemIndex].posX, itemSlots[itemIndex].posY)
			if isPlayer:
				item.mouse_enter.connect(_on_item_mouse_enter)
				item.mouse_leave.connect(_on_item_mouse_leave)
				item.click.connect(_on_item_click)
			$Background.add_sibling(item)
			itemSlots[itemIndex].item = item
			return true
	return false

func initRound() -> void:
	var roundObject = roundsConfiguration[currentRound]
	player.resetHealth(roundObject.health)
	dealer.resetHealth(roundObject.health)
	for itemIndex in roundObject.items:
		tryPlacingNewItem(null, true)
		tryPlacingNewItem(null, false)
	shotgunReload()

func nextRound() -> void:
	var roundObject = roundsConfiguration[currentRound]
	if roundObject.id == 2:
		$WinScreen.show()
		get_tree().paused = true
		changeMouseDisplay(Global.MouseOption.VISIBLE)
	else:
		currentRound = currentRound + 1
		initRound()

func getCountingText() -> String:
	var blankShells = shells.count(Global.ShellType.BLANK)
	var liveShells = len(shells) - blankShells
	var blankText = " blanks." if blankShells > 1 else " blank."
	var liveText = " live rounds." if liveShells > 1 else " live round."
	return str(liveShells, liveText, blankShells, blankText)

func getShufflingText() -> String:
	const lines = [
		"I insert the shells in an unknown order.",
		"They enter the chamber in a hidden sequence.",
		"The shells are loaded randomly."
	]
	return lines[randi_range(0, len(lines) - 1)]

func displayShellsAndThenHideThem() -> void:
	for index in len(shells):
		var newShell = Shell.instantiate()
		newShell.setProperties(shells[index])
		newShell.position.x = index * 16
		$DisplayedShells.add_child(newShell)
	await dialog.display(getCountingText())
	for n in $DisplayedShells.get_children():
		n.queue_free()
	await dialog.display(getShufflingText())
	shells.shuffle()
	nextTurn(true)

func shotgunReload() -> void:
	var roundObject = roundsConfiguration[currentRound]
	for n in $ShellEjection.get_children():
		n.queue_free()
	shells = []
	shells.push_back(Global.ShellType.LIVE)
	shells.push_back(Global.ShellType.BLANK)
	for n in randi_range(roundObject.min, roundObject.max) - 2:
		if randi() % 2 == 0:
			shells.push_back(Global.ShellType.LIVE)
		else:
			shells.push_back(Global.ShellType.BLANK)
	displayShellsAndThenHideThem()

func seekAndUseItem(type) -> bool:
	await get_tree().create_timer(gameDelay / 2).timeout
	var itemStatus
	for index in len(dealerItemSlots):
		if dealerItemSlots[index].item:
			itemStatus = dealerItemSlots[index].item.getStatus()
			if itemStatus.isActive and itemStatus.type == type:
				useItem(type, false)
				dealerItemSlots[index].item.queue_free()
				dealerItemSlots[index].item = null
				return true
	return false

func setIsActiveAllItems(type, isPlayer: bool, newVal: bool) -> void:
	var item
	var itemStatus
	var itemSlots = dealerItemSlots
	if isPlayer:
		itemSlots = playerItemSlots
	for index in len(itemSlots):
		if dealerItemSlots[index].item:
			itemStatus = dealerItemSlots[index].item.getStatus()
			if itemStatus.type == type:
				dealerItemSlots[index].item.setIsActive(newVal)

func dealerChoice() -> bool:
	changeMouseDisplay(Global.MouseOption.CAPTURED)
	var assumeNextShellIsBlank = false
	var blankShells = shells.count(Global.ShellType.BLANK)
	await get_tree().create_timer(gameDelay).timeout
	if dealer.isHurt():
		if await seekAndUseItem(Global.ItemType.CIGS):
			return await dealerChoice()
	await seekAndUseItem(Global.ItemType.HANDCUFFS)
	if len(shells) > 1 and not nextShellKnowledge:
		if blankShells == len(shells) - blankShells:
			assumeNextShellIsBlank = randi() % 2 == 0
		else:
			assumeNextShellIsBlank = blankShells > len(shells) - blankShells
		if await seekAndUseItem(Global.ItemType.LENS):
			nextShellKnowledge = true
			return await dealerChoice()
	else:
		assumeNextShellIsBlank = shells[0] == Global.ShellType.BLANK
	nextShellKnowledge = false
	if assumeNextShellIsBlank:
		if await seekAndUseItem(Global.ItemType.INVERTER):
			return await aimAndShoot(true)
		if len(shells) - blankShells > 0:
			if await seekAndUseItem(Global.ItemType.BEER):
				return await dealerChoice()
		return await aimAndShoot(false)
	else:
		await seekAndUseItem(Global.ItemType.KNIFE)
		return await aimAndShoot(true)

func nextTurn(playerTurn: bool) -> void:
	isPlayerTurn = playerTurn
	setIsActiveAllItems(Global.ItemType.HANDCUFFS, true, true)
	setIsActiveAllItems(Global.ItemType.HANDCUFFS, false, true)
	if isPlayerTurn:
		if isPlayerTurnBlocked:
			isPlayerTurnBlocked = false
			nextTurn(false)
		else:
			$Shotgun.setIsActive(true)
			changeMouseDisplay(Global.MouseOption.VISIBLE)
	else:
		if isDealerTurnBlocked:
			isDealerTurnBlocked = false
			nextTurn(true)
		else:
			dealerChoice()

func useItem(type, isPlayer) -> void:
	var shellTypeStr = "live."
	if shells[0] == Global.ShellType.BLANK:
		shellTypeStr = "blank."
	toggleHoverTexts("", "")
	changeMouseDisplay(Global.MouseOption.CAPTURED)
	if type == Global.ItemType.LENS:
		if isPlayer:
			toggleHoverTexts("", str("Next shell is ", shellTypeStr))
		else:
			await dialog.display("Interesting...")
	await get_tree().create_timer(gameDelay / 2).timeout
	if type == Global.ItemType.KNIFE:
		shotgunDamage = shotgunDamage * 2
	if type == Global.ItemType.HANDCUFFS:
		isDealerTurnBlocked = isPlayer
		isPlayerTurnBlocked = not isPlayer
		setIsActiveAllItems(Global.ItemType.HANDCUFFS, isPlayer, false)
	if type == Global.ItemType.BEER:
		rack()
	if type == Global.ItemType.INVERTER:
		if shells[0] == Global.ShellType.BLANK:
			shells[0] = Global.ShellType.LIVE
		else:
			shells[0] = Global.ShellType.BLANK
	if type == Global.ItemType.CIGS:
		if isPlayer:
			player.changeHealth(1)
		else:
			dealer.changeHealth(1)
	toggleHoverTexts("", "")
	changeMouseDisplay(Global.MouseOption.LAST_MODE)

func aimAndShoot(onPlayer: bool) -> bool:
	$Shotgun.setIsActive(false)
	if onPlayer:
		shotgunTarget = 90
	else:
		shotgunTarget = -90
	await get_tree().create_timer(gameDelay / 2).timeout
	shoot(onPlayer)
	await get_tree().create_timer(gameDelay / 2).timeout
	shotgunTarget = 0
	return true

func rack() -> void:
	var currentShell = shells.pop_front()
	var newMovingShell = Shell.instantiate()
	newMovingShell.setProperties(currentShell, true)
	$ShellEjection.add_child(newMovingShell)
	if len(shells) == 0:
		isPlayerTurn = false
		await get_tree().create_timer(gameDelay).timeout
		shotgunReload()

func shoot(onPlayer: bool) -> void:
	var currentShell = shells.pop_front()
	var isBlank = currentShell == Global.ShellType.BLANK
	var playerIsDead
	var dealerIsDead
	if currentShell == Global.ShellType.LIVE:
		if onPlayer:
			playerIsDead = player.changeHealth(-shotgunDamage)
		else:
			dealerIsDead = dealer.changeHealth(-shotgunDamage)
	shotgunDamage = shotgunBaseDamage
	var newMovingShell = Shell.instantiate()
	newMovingShell.setProperties(currentShell, true)
	$ShellEjection.add_child(newMovingShell)
	if playerIsDead:
		await get_tree().create_timer(gameDelay).timeout
		$GameOverScreen.show()
		get_tree().paused = true
		changeMouseDisplay(Global.MouseOption.VISIBLE)
	elif dealerIsDead:
		isPlayerTurn = false
		await get_tree().create_timer(gameDelay).timeout
		nextRound()
	elif len(shells) == 0:
		isPlayerTurn = false
		await get_tree().create_timer(gameDelay).timeout
		shotgunReload()
	else:
		if isPlayerTurn:
			nextTurn(isBlank and onPlayer)
		else:
			nextTurn(not isBlank or onPlayer)

func toggleHoverTexts(title, description) -> void:
	if len(title) > 0 or len(description) > 0:
		$HoverTitle.text = title
		$HoverDescription.text = description
		$HoverTitle.show()
		$HoverDescription.show()
	else:
		$HoverTitle.hide()
		$HoverDescription.hide()

func _on_continue_pressed() -> void:
	$PauseMenu.hide()
	get_tree().paused = false
	changeMouseDisplay(Global.MouseOption.LAST_MODE)

func _on_quit_pressed() -> void:
	$PauseMenu.hide()
	$GameOverScreen.hide()
	$WinScreen.hide()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_character_click(onPlayer: bool) -> void:
	player.setIsActive(false)
	dealer.setIsActive(false)
	if isPlayerTurn:
		aimAndShoot(onPlayer)

func _on_item_mouse_enter(t, d) -> void:
	toggleHoverTexts(t, d)

func _on_item_mouse_leave() -> void:
	toggleHoverTexts("", "")

func _on_item_click(type) -> void:
	if isPlayerTurn:
		useItem(type, true)

func _on_shotgun_click() -> void:
	toggleHoverTexts("", "")
	$Shotgun.setIsActive(false)
	player.setIsActive(true)
	dealer.setIsActive(true)
