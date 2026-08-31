extends Node2D

@export var Shell: PackedScene
@export var Character: PackedScene
@export var Dialog: PackedScene

var dealer
var player
var dialog
var shells = []
var gameSpeed: float
var gameDelay: float
var lastMouseMode
const roundsConfiguration = [
	{ "id": 0, "health": 2, "min": 2, "max": 4, "objects": 0 },
	{ "id": 1, "health": 4, "min": 3, "max": 6, "objects": 2 },
	{ "id": 2, "health": 6, "min": 4, "max": 8, "objects": 4 },
]
var currentRound = 0
var shotgun
var shotgunRotation: float = 0
var shotgunTarget: float = 0
var isPlayerTurn = false

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
	await get_tree().create_timer(gameDelay).timeout
	shotgunReload()

func _process(delta: float) -> void:
	if shotgunRotation < shotgunTarget:
		shotgunRotation = shotgunRotation + gameSpeed
	if shotgunRotation > shotgunTarget:
		shotgunRotation = shotgunRotation - gameSpeed
	$Shotgun.rotation = deg_to_rad(shotgunRotation)
	if Input.is_action_just_pressed("pause"):
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

func initRound() -> void:
	var roundObject = roundsConfiguration[currentRound]
	player.resetHealth(roundObject.health)
	dealer.resetHealth(roundObject.health)
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
	shells.push_back(Global.ShellType.LIVE)
	shells.push_back(Global.ShellType.BLANK)
	for n in randi_range(roundObject.min, roundObject.max) - 2:
		if randi() % 2 == 0:
			shells.push_back(Global.ShellType.LIVE)
		else:
			shells.push_back(Global.ShellType.BLANK)
	displayShellsAndThenHideThem()

func nextTurn(playerTurn: bool) -> void:
	isPlayerTurn = playerTurn
	if isPlayerTurn:
		$Shotgun.setIsActive(true)
		changeMouseDisplay(Global.MouseOption.VISIBLE)
	else:
		changeMouseDisplay(Global.MouseOption.CAPTURED)
		await get_tree().create_timer(gameDelay).timeout
		var blankShells = shells.count(Global.ShellType.BLANK)
		aimAndShoot(blankShells < len(shells) - blankShells)

func aimAndShoot(onPlayer: bool) -> void:
	$Shotgun.setIsActive(false)
	if onPlayer:
		shotgunTarget = 90
	else:
		shotgunTarget = -90
	await get_tree().create_timer(gameDelay / 2).timeout
	shoot(onPlayer)
	await get_tree().create_timer(gameDelay / 2).timeout
	shotgunTarget = 0

func shoot(onPlayer: bool) -> void:
	var currentShell = shells.pop_front()
	var isBlank = currentShell == Global.ShellType.BLANK
	var playerIsDead
	var dealerIsDead
	if currentShell == Global.ShellType.LIVE:
		if onPlayer:
			playerIsDead = player.changeHealth(-1)
		else:
			dealerIsDead = dealer.changeHealth(-1)
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
	elif (len(shells) == 0):
		isPlayerTurn = false
		await get_tree().create_timer(gameDelay).timeout
		shotgunReload()
	else:
		if isPlayerTurn:
			nextTurn(isBlank and onPlayer)
		else:
			nextTurn(not isBlank or onPlayer)

func toggleHoverTexts(title, description) -> void:
	if len(title) > 0 and len(description) > 0:
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

func _on_shotgun_mouse_enter(t, d) -> void:
	toggleHoverTexts(t, d)

func _on_shotgun_mouse_leave() -> void:
	toggleHoverTexts("", "")

func _on_shotgun_click() -> void:
	toggleHoverTexts("", "")
	$Shotgun.setIsActive(false)
	player.setIsActive(true)
	dealer.setIsActive(true)
