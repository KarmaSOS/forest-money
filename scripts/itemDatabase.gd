extends Node

var _items_by_id: Dictionary = {}
var _items_list: Array[ItemData] = []

const RAW_ITEMS: Array[Dictionary] = [
	{
		"id": "ariel_axe",
		"item_name": "Kapak Ariel",
		"type": "tool",
		"price": 100,
		"short_desc": "digunakan untuk menembang kayu... ya",
		"icon_path": "res://assets/images/items/kapak.png",
		"stackable": true,
		"max_stack": 4,
		"default_stock" : 64,
		"stats": {
			"damage": 10,
			"stamina_cost": 5
		},
		"effects": []
	},
	{
		"id": "jerrycan",
		"item_name": "bensin",
		"type": "tool",
		"price": 40,
		"short_desc": "bahan fosil terbaik abad ini",
		"icon_path": "res://assets/images/items/Jerrycan assets.png",
		"stackable": true,
		"max_stack": 4,
		"default_stock" : 64,
		"stats": {
			"damage": 0,
			"stamina_cost": 0
		},
		"effects": [
			{"id": "burn", "damage": 5, "duration": 3.0}
		]
	},
	{
		"id": "korek_api",
		"item_name": "korek api",
		"type": "tool",
		"price": 1,
		"short_desc": "untuk menyulut api",
		"icon_path": "res://assets/images/items/Korek_Kayu.png",
		"stackable": true,
		"max_stack": 64,
		"default_stock" : 64,
		"stats": {
			"damage": 0
		},
		"effects": []
	},
	{
		"id": "log",
		"item_name": "log",
		"type": "material",
		"price": 10,
		"short_desc": "pohon yang telah mati",
		"icon_path": "res://assets/images/icons/logs.png",
		"stackable": true,
		"max_stack": 800,
		"default_stock" : 64,
		"stats": {
			"damage": 10
		},
		"effects": []
	},
]

func _ready() -> void:
	_load_catalog()


func _load_catalog() -> void:
	_items_by_id.clear()
	_items_list.clear()
	
	for raw in RAW_ITEMS:
		var item := ItemData.from_dict(raw)
		if item.id.is_empty():
			push_warning("ItemDatabase: Item tanpa 'id' dilewati.")
			continue
		
		if _items_by_id.has(item.id):
			push_warning("ItemDatabase: Duplikat item id '%s', menimpa data lama." % item.id)
		
		_items_by_id[item.id] = item
		_items_list.append(item)


func get_all_items() -> Array[ItemData]:
	return _items_list.duplicate()


func get_item(item_id: String) -> ItemData:
	return _items_by_id.get(item_id, null)


func get_items_by_type(item_type: String) -> Array[ItemData]:
	if item_type.is_empty() or item_type == "all":
		return get_all_items()
	
	var filtered: Array[ItemData] = []
	for item in _items_list:
		if item.type == item_type:
			filtered.append(item)
	return filtered
