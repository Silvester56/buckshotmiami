extends Sprite2D

func setProperties(value: float) -> void:
	if value == 0:
		frame = 2
	if value == 0.5:
		frame = 1
	if value == 1:
		frame = 0
