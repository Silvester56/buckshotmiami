extends Node2D

@export var Mask: PackedScene

func _ready() -> void:
	var startPositionX = 64;
	var startPositionY = 64;
	var newPositionX = 0;
	var newPositionY = 0;
	var gap = 96
	var totalMasks = 4
	for maskNumber in totalMasks:
		var mask = Mask.instantiate()
		newPositionX = startPositionX + gap * (maskNumber % 2)
		newPositionY = startPositionY + gap * (maskNumber / 2)
		mask.setProperties(maskNumber, newPositionX, newPositionY)
		mask.mouse_enter.connect(_on_mask_mouse_enter)
		mask.mouse_leave.connect(_on_mask_mouse_leave)
		add_child(mask)

func toggleHoverTexts(title, description) -> void:
	if len(title) > 0 or len(description) > 0:
		$HoverTitle.text = title
		$HoverDescription.text = description
		$HoverTitle.show()
		$HoverDescription.show()
	else:
		$HoverTitle.hide()
		$HoverDescription.hide()

func _on_mask_mouse_enter(t, d) -> void:
	toggleHoverTexts(t, d)

func _on_mask_mouse_leave() -> void:
	toggleHoverTexts("", "")
