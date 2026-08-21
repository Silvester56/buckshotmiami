extends Node2D

@export var Shell: PackedScene

var maxPlayerHealth = 0
var maxDealerHealth = 0
var dealerHealth = 0
var playerHealth = 0
var shells = []
var roundsConfiguration = [
	{ "id": 0, "health": 2, "min": 2, "max": 4, "objects": 0 },
	{ "id": 1, "health": 4, "min": 3, "max": 6, "objects": 2 },
	{ "id": 2, "health": 6, "min": 4, "max": 8, "objects": 4 },
]
var currentRound = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var roundObject = roundsConfiguration[currentRound]
	maxPlayerHealth = roundObject.health
	maxDealerHealth = roundObject.health
	playerHealth = maxPlayerHealth
	dealerHealth = maxDealerHealth
	$DealerHealth.text = str("Health : ", dealerHealth)
	$PlayerHealth.text = str("Health : ", playerHealth)
	shells.push_back(ShellType.LIVE)
	shells.push_back(ShellType.BLANK)
	for n in randi_range(roundObject.min, roundObject.max) - 2:
		if randi() % 2 == 0:
			shells.push_back(ShellType.LIVE)
		else:
			shells.push_back(ShellType.BLANK)
	displayShells()
	shells.shuffle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
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
			changeHealth(isPlayer, -1)

func changeHealth(isPlayer: bool, delta: int) -> void:
	if isPlayer:
		playerHealth = clampi(playerHealth + delta, 0, maxPlayerHealth)
	else:
		dealerHealth = clampi(dealerHealth + delta, 0, maxDealerHealth)
	$DealerHealth.text = str("Health : ", dealerHealth)
	$PlayerHealth.text = str("Health : ", playerHealth)

func _on_continue_pressed() -> void:
	$PauseMenu.hide()
	get_tree().paused = false

func _on_quit_pressed() -> void:
	$PauseMenu.hide()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_dealer_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MouseButton.MOUSE_BUTTON_LEFT \
	and event.is_pressed():
		shoot(false)

func _on_player_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MouseButton.MOUSE_BUTTON_LEFT \
	and event.is_pressed():
		shoot(true)

func _on_displayed_shells_timer_timeout() -> void:
	for n in $DisplayedShells.get_children():
		n.queue_free()
