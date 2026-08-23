extends Sprite2D

signal character_click

@export var Heart: PackedScene

var maxHealth: int
var health: int
var isPlayer: bool
var isHoverTextVisible: bool = false

func setProperties(isPl, maxHe, posX, posY) -> void:
	isPlayer = isPl
	maxHealth = maxHe
	health = maxHealth
	position.x = posX
	position.y = posY
	drawHealth()
	if isPlayer:
		frame = 2
		$Health.position.y = 40
		$HoverLabel.text = "YOU"
	else:
		$Health.position.y = -40
		$HoverLabel.text = "DEALER"

func resetHealth(newValue: int) -> void:
	maxHealth = newValue
	health = maxHealth
	drawHealth()

func changeHealth(delta: int) -> bool:
	health = clampi(health + delta, 0, maxHealth)
	drawHealth()
	return health == 0

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

func setIsHoverTextVisible(newVal: bool) -> void:
	isHoverTextVisible = newVal
	if not newVal:
		self_modulate = Color.WHITE
		$HoverLabel.hide()

func _on_character_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MouseButton.MOUSE_BUTTON_LEFT \
	and event.is_pressed():
		emit_signal("character_click", isPlayer)

func _on_character_area_mouse_entered() -> void:
	if isHoverTextVisible:
		self_modulate = Color.BLACK
		$HoverLabel.show()

func _on_character_area_mouse_exited() -> void:
	self_modulate = Color.WHITE
	$HoverLabel.hide()
