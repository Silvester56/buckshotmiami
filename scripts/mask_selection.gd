extends Control

@export var MaskButton: PackedScene

var listOfMasks = [
	{"id": 0, "label": "Richard"},
	{"id": 1, "label": "Rasmus"},
	{"id": 2, "label": "Tony"},
	{"id": 3, "label": "Aubrey"},
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var newPositionY = 0;
	for mask in listOfMasks:
		var maskButton = MaskButton.instantiate()
		newPositionY = newPositionY + 100
		maskButton.position.y = newPositionY
		maskButton.text = mask.label
		add_child(maskButton)
