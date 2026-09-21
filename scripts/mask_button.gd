extends Button

signal click
var maskId

func setProperties(id, t, posY) -> void:
	maskId = id
	text = t
	position.y = posY

func _on_pressed() -> void:
	emit_signal("click", maskId)
