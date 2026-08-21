extends Sprite2D

signal character_click

var maxHealth: int
var health: int
var isPlayer: bool

func setProperties(isPl, maxHe, posX, posY) -> void:
	isPlayer = isPl
	maxHealth = maxHe
	health = maxHealth
	position.x = posX
	position.y = posY
	$Health.text = str("HP : ", health)
	if isPlayer:
		frame = 0
	else:
		frame = 2

func changeHealth(delta: int) -> void:
	health = clampi(health + delta, 0, maxHealth)
	$Health.text = str("HP : ", health)

func _on_character_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MouseButton.MOUSE_BUTTON_LEFT \
	and event.is_pressed():
		emit_signal("character_click", isPlayer)
