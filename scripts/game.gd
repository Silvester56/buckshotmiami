extends Node2D

@export var Shell: PackedScene
@export var Character: PackedScene

var dealer
var player
var shells = []
var roundsConfiguration = [
	{ "id": 0, "health": 2, "min": 2, "max": 4, "objects": 0 },
	{ "id": 1, "health": 4, "min": 3, "max": 6, "objects": 2 },
	{ "id": 2, "health": 6, "min": 4, "max": 8, "objects": 4 },
]
var currentRound = 0

func _ready() -> void:
	var roundObject = roundsConfiguration[currentRound]
	var distanceFromBorder = 50
	player = Character.instantiate()
	player.setProperties(true, roundObject.health, 256, 512 - distanceFromBorder)
	player.character_click.connect(shoot)
	dealer = Character.instantiate()
	dealer.setProperties(false, roundObject.health, 256, distanceFromBorder)
	dealer.character_click.connect(shoot)
	$Background.add_sibling(player)
	$Background.add_sibling(dealer)
	shells.push_back(ShellType.LIVE)
	shells.push_back(ShellType.BLANK)
	for n in randi_range(roundObject.min, roundObject.max) - 2:
		if randi() % 2 == 0:
			shells.push_back(ShellType.LIVE)
		else:
			shells.push_back(ShellType.BLANK)
	displayShells()
	shells.shuffle()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		$PauseMenu.show()
		get_tree().paused = true

func displayShells() -> void:
	for index in len(shells):
		var newShell = Shell.instantiate()
		newShell.setProperties(shells[index])
		newShell.position.x = index * 16
		$DisplayedShells.add_child(newShell)
	$DisplayedShellsTimer.start()

func shoot(isPlayer: bool) -> void:
	if (len(shells) > 0):
		var current_shell = shells.pop_front()
		if current_shell == ShellType.LIVE:
			if isPlayer:
				player.changeHealth(-1)
			else:
				dealer.changeHealth(-1)

func _on_continue_pressed() -> void:
	$PauseMenu.hide()
	get_tree().paused = false

func _on_quit_pressed() -> void:
	$PauseMenu.hide()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_displayed_shells_timer_timeout() -> void:
	for n in $DisplayedShells.get_children():
		n.queue_free()
