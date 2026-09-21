class_name Global

enum ShellType { LIVE, BLANK, LETHAL, HEAL }
enum MouseOption { VISIBLE, CAPTURED, LAST_MODE }
enum ItemType { KNIFE, HANDCUFFS, LENS, BEER, INVERTER, CIGS }

static var selectedMask

static func setMask(newVal) -> void:
	selectedMask = newVal

static func getMask() -> Dictionary:
	return selectedMask
