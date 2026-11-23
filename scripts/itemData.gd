class_name ItemData
extends Resource

@export var id: String = ""
@export var item_name: String = ""
@export var type: String = "" 
@export var price: int = 0
@export_multiline var short_desc: String = ""
@export var icon: Texture2D
@export var icon_path: String = ""

@export var stackable: bool = true
@export var max_stack: int = 99
@export var default_stock: int = 0

@export var stats: Dictionary = {}
@export var effects: Array[Dictionary] = []


## Membuat instance ItemData dari Dictionary 
static func from_dict(data: Dictionary) -> ItemData:
	var item := ItemData.new()
	item.id = str(data.get("id", ""))
	item.item_name = str(data.get("item_name", "Unnamed Item"))
	item.type = str(data.get("type", "misc"))
	item.price = int(data.get("price", 0))
	item.short_desc = str(data.get("short_desc", ""))
	item.icon_path = str(data.get("icon_path", ""))
	
	if item.icon_path != "" and ResourceLoader.exists(item.icon_path):
		item.icon = load(item.icon_path)
	
	item.stackable = bool(data.get("stackable", true))
	item.max_stack = int(data.get("max_stack", 99 if item.stackable else 1))
	item.default_stock = int(data.get("default_stock", 0))
	
	var raw_stats = data.get("stats", {})
	if raw_stats is Dictionary:
		item.stats = raw_stats.duplicate(true)
	
	var raw_effects = data.get("effects", [])
	if raw_effects is Array:
		for eff in raw_effects:
			if eff is Dictionary:
				item.effects.append(eff.duplicate(true))
	
	return item
