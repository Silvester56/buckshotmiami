extends Sprite2D

class_name ClickableEntity

signal click
signal mouse_enter
signal mouse_leave

@export var title: String
@export var description: String

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MouseButton.MOUSE_BUTTON_LEFT \
	and event.is_pressed():
		emit_signal("click")

func _on_area_2d_mouse_entered() -> void:
	emit_signal("mouse_enter", title, description)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("mouse_leave")
