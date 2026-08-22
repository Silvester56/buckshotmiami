extends Node2D

@export var Shell: PackedScene
@export var Character: PackedScene

var dealer
var player
var shells = []
const gameDelay = 3
const roundsConfiguration = [
	{ "id": 0, "health": 2, "min": 2, "max": 4, "objects": 0 },
	{ "id": 1, "health": 4, "min": 3, "max": 6, "objects": 2 },
	{ "id": 2, "health": 6, "min": 4, "max": 8, "objects": 4 },
]
var currentRound = 0
var isPlayerTurn = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var roundObject = roundsConfiguration[currentRound]
	var distanceFromBorder = 50
	player = Character.instantiate()
	player.setProperties(true, roundObject.health, 256, 512 - distanceFromBorder)
	player.character_click.connect(_on_character_click)
	dealer = Character.instantiate()
	dealer.setProperties(false, roundObject.health, 256, distanceFromBorder)
	dealer.character_click.connect(_on_character_click)
	$Background.add_sibling(player)
	$Background.add_sibling(dealer)
	shotgunReload()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		$PauseMenu.show()
		get_tree().paused = true

func displayShellsAndThenHideThem() -> void:
	for index in len(shells):
		var newShell = Shell.instantiate()
		newShell.setProperties(shells[index])
		newShell.position.x = index * 16
		$DisplayedShells.add_child(newShell)
	await get_tree().create_timer(gameDelay).timeout
	for n in $DisplayedShells.get_children():
		n.queue_free()
	shells.shuffle()
	nextTurn(true)

func shotgunReload() -> void:
	var roundObject = roundsConfiguration[currentRound]
	for n in $ShellEjection.get_children():
		n.queue_free()
	shells.push_back(ShellType.LIVE)
	shells.push_back(ShellType.BLANK)
	for n in randi_range(roundObject.min, roundObject.max) - 2:
		if randi() % 2 == 0:
			shells.push_back(ShellType.LIVE)
		else:
			shells.push_back(ShellType.BLANK)
	displayShellsAndThenHideThem()

func nextTurn(playerTurn: bool) -> void:
	isPlayerTurn = playerTurn
	player.setIsHoverTextVisible(isPlayerTurn)
	dealer.setIsHoverTextVisible(isPlayerTurn)
	if isPlayerTurn:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		await get_tree().create_timer(gameDelay).timeout
		var blankShells = shells.count(ShellType.BLANK)
		shoot(blankShells < len(shells) - blankShells)

func shoot(onPlayer: bool) -> void:
	var currentShell = shells.pop_front()
	var isBlank = currentShell == ShellType.BLANK
	if currentShell == ShellType.LIVE:
		if onPlayer:
			player.changeHealth(-1)
		else:
			dealer.changeHealth(-1)
	var newMovingShell = Shell.instantiate()
	newMovingShell.setProperties(currentShell, true)
	$ShellEjection.add_child(newMovingShell)
	if (len(shells) == 0):
		isPlayerTurn = false
		await get_tree().create_timer(gameDelay).timeout
		shotgunReload()
	else:
		if isPlayerTurn:
			nextTurn(isBlank and onPlayer)
		else:
			nextTurn(not isBlank or onPlayer)

func _on_continue_pressed() -> void:
	$PauseMenu.hide()
	get_tree().paused = false

func _on_quit_pressed() -> void:
	$PauseMenu.hide()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_character_click(onPlayer: bool) -> void:
	if isPlayerTurn:
		shoot(onPlayer)
