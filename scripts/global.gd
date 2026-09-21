class_name Global

enum ShellType { LIVE, BLANK, LETHAL, HEAL }
enum MouseOption { VISIBLE, CAPTURED, LAST_MODE }
enum ItemType { KNIFE, HANDCUFFS, LENS, BEER, INVERTER, CIGS }

static var maskAbility = {
	"healthBonus": 0,
	"itemStart": null,
	"shotgunBaseDamage": 1
}

static func setMaskAbility(key, value) -> void:
	if key and value:
		maskAbility[key] = value

static func getMaskAbility(key):
	return maskAbility[key]
