extends Sprite2D

var type = ShellType.LIVE

func setProperties(ty: ShellType) -> void:
	type = ty
	if (type == ShellType.BLANK):
		frame = 1
	if (type == ShellType.LETHAL):
		frame = 2
	if (type == ShellType.HEAL):
		frame = 3

func getType() -> ShellType:
	return type
