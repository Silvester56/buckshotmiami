extends Sprite2D

var type = ShellType.LIVE
var moving = false
var speed = 500
var angle = randi_range(0, 359)
var direction = Vector2(cos(deg_to_rad(angle)), sin(deg_to_rad(angle)))

func _physics_process(_delta: float) -> void:
	if moving:
		position = position + direction * speed * _delta
		rotation = rotation + 0.5

func setProperties(ty, isEjected = false) -> void:
	type = ty
	if type == ShellType.BLANK:
		frame = 1
	if type == ShellType.LETHAL:
		frame = 2
	if type == ShellType.HEAL:
		frame = 3
	moving = isEjected
	if moving:
		$EjectionTimer.autostart = true

func getType() -> ShellType:
	return type

func _on_ejection_timer_timeout() -> void:
	moving = false
