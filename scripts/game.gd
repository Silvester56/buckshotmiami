extends Node2D

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
	playerHealth = roundObject.health
	dealerHealth = roundObject.health
	$DealerHealth.text = str("Health : ", dealerHealth)
	$PlayerHealth.text = str("Health : ", playerHealth)
	for n in randi_range(roundObject.min, roundObject.max):
		shells.push_back(randi() % 2 == 0)
	shells.shuffle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		$PauseMenu.show()
		get_tree().paused = true

func _on_continue_pressed() -> void:
	$PauseMenu.hide()
	get_tree().paused = false

func _on_quit_pressed() -> void:
	$PauseMenu.hide()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
