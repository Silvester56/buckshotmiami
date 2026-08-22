extends Sprite2D

signal character_click

@export var Heart: PackedScene

var maxHealth: int
var health: int
var isPlayer: bool

func setProperties(isPl, maxHe, posX, posY) -> void:
	isPlayer = isPl
	maxHealth = maxHe
	health = maxHealth
	position.x = posX
	position.y = posY
	drawHealth()
	if isPlayer:
		frame = 0
		$Health.position.y = 40
	else:
		frame = 2
		$Health.position.y = -40

func changeHealth(delta: int) -> void:
	health = clampi(health + delta, 0, maxHealth)
	drawHealth()

func drawHealth() -> void:
	for h in $Health.get_children():
		h.queue_free()
	for n in maxHealth:
		var newHeart = Heart.instantiate()
		if n + health < maxHealth:
			newHeart.setProperties(0)
		else:
			newHeart.setProperties(1)
		newHeart.position.x = (maxHealth - n - 1) * 16
		$Health.add_child(newHeart)

func _on_character_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MouseButton.MOUSE_BUTTON_LEFT \
	and event.is_pressed():
		emit_signal("character_click", isPlayer)
