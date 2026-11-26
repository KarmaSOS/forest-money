extends Node

const SAVE_PATH: String = "user://savegame.json"
signal money_update(new_value: int)
signal energy_update(new_value: int)
signal inventory_update(item_id: String, new_value: int)
signal stock_update(item_id: String, new_value: int)

# game variable
const DEFAULT_DATA: Dictionary = {
	"day": 1,
	"energy": 100,
	"money": 100,
	"skor_kerusakan_hutan": 0,
	"inventory": {
		"log" : 100,
	}
}

var day: int = DEFAULT_DATA["day"]
var energy: int = DEFAULT_DATA["energy"]:
	set(value):
		energy = value
		energy_update.emit(energy)
var money: int = DEFAULT_DATA["money"]:
	set(value):
		money = value
		money_update.emit(money)
var skor_kerusakan_hutan: int = DEFAULT_DATA["skor_kerusakan_hutan"]
var inventory: Dictionary = DEFAULT_DATA["inventory"].duplicate()


var shop_stock: Dictionary = {}
func restock_shop() -> void:
	shop_stock.clear()
	for item in ItemDatabase.get_all_items():
		shop_stock[item.id] = item.default_stock
	print("hasil restock", shop_stock)
	
		
func get_stock(item_id: String) -> Variant:
	if item_id == "":
		return shop_stock.duplicate()
	else:
		print("mencari stock")
		return shop_stock.get(item_id, 0)
	
	

func buy_item(item_id: String, request: int = 1) -> bool:
	var item = ItemDatabase.get_item(item_id)
	if item == null:
		print("item tidak ditemukan")
		return false
		
	var current_stock = get_stock(item_id)
	if request <= 0 or request > current_stock:
		print("request: ", request)
		print("requestnya tidak masuk akal")
		return false
		
	var total_harga = item.price * request
	
	if money >= total_harga:
		money -= total_harga
		
		add_item(item_id, request)
		shop_stock[item_id] = current_stock - request
		stock_update.emit(item_id, shop_stock[item_id])
		print("pembelian berhasil")
		return true
	else:
		print("money tidak cukup!")
		return false
		
func sell_item(item_id : String, request: int = 1) -> bool:
	var current_stock : int = get_item_count(item_id)
	if request <= 0:
		print("jumlahnya tidak masuk akal")
		return false
	if current_stock <= 0:
		print("item tidak tersedia")
		return false
	if request > current_stock:
		print("item tidak cukup")
		return false
	
	var item = ItemDatabase.get_item(item_id);
	if item == null: return false
	
	money += item.price * request
	sub_item(item_id, request)
	

	print("pembelian berhasil")
	return true

func add_item(item_id: String, jumlah: int =1)-> void:
	if inventory.has(item_id):
		inventory[item_id] += jumlah
	else:
		inventory[item_id] = jumlah
		
	inventory_update.emit(item_id, get_item_count(item_id))
	
func sub_item(item_id: String, jumlah: int = 1)-> void:
	var current_stock : int = inventory.get(item_id, 0)
	inventory[item_id] = current_stock - jumlah
	
	if inventory[item_id] <= 0:
		inventory.erase(item_id)

	inventory_update.emit(item_id, get_item_count(item_id))

func get_inventory_items(filter_type: String = "all") -> Array[ItemData]:
	var daftar_item: Array[ItemData] = []
	
	for item_id in inventory.keys():
		if inventory[item_id] > 0:
			var item_data: ItemData = ItemDatabase.get_item(item_id)
			
			# Jika data valid, cek apakah sesuai dengan tab filter (all / tool / seed)
			if item_data != null:
				if filter_type.is_empty() or filter_type == "all" or item_data.type == filter_type:
					daftar_item.append(item_data)
					
	return daftar_item


func get_save_data() -> Dictionary:
	return {
		"day": day,
		"energy": energy,
		"money": money,
		"skor_kerusakan_hutan": skor_kerusakan_hutan
	}

# menyimpan variable ke user data
func save_game():
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(get_save_data(), "\t")) # "\t" agar file JSON rapi & mudah dibaca
		print("Game berhasil disimpan!")


func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("Belum ada file save, pakai data default.")
		return
		
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		if parsed is Dictionary:
			day = parsed.get("day", DEFAULT_DATA["day"])
			energy = parsed.get("energy", DEFAULT_DATA["energy"])
			money = parsed.get("money", DEFAULT_DATA["money"])
			skor_kerusakan_hutan = parsed.get("skor_kerusakan_hutan", DEFAULT_DATA["skor_kerusakan_hutan"])
			print("Data game berhasil dimuat!")
		else:
			print("Format file JSON tidak valid.")

func reset_game():
	day = DEFAULT_DATA["day"]
	energy = DEFAULT_DATA["energy"]
	money = DEFAULT_DATA["money"]
	skor_kerusakan_hutan = DEFAULT_DATA["skor_kerusakan_hutan"]
	save_game()
	print("Game telah di-reset ke kondisi awal!")
	
func _ready():
	restock_shop()
	load_game()
	
func get_item_count(id: String) -> int:
	return inventory.get(id, 0)
	
#SCENE
var previous_scene_path: String = ""

func goto_scene(target_path: String) -> void:
	if get_tree().current_scene:
		previous_scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(target_path)

func go_back() -> void:
	if previous_scene_path != "":
		get_tree().change_scene_to_file(previous_scene_path)
	else:
		print("Tidak ada halaman sebelumnya.")

	
