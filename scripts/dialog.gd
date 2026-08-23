extends Control

var delayBetweenCharacters: float
var delayBeforeHiding: float

func setProperties(posX: float, posY: float, delay: float) -> void:
	position.x = posX
	position.y = posY
	delayBetweenCharacters = delay / 10
	delayBeforeHiding = delay

func display(text: String) -> void:
	$Label.visible_characters = 0
	$Label.text = text
	show()
	while $Label.visible_characters < len(text):
		await get_tree().create_timer(delayBetweenCharacters).timeout
		$Label.visible_characters = $Label.visible_characters + 1
	await get_tree().create_timer(delayBeforeHiding).timeout
	hide()
