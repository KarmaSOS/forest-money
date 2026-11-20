extends Node

const SAVE_PATH: String = "user://savegame.json"
signal money_update(new_value: int)
signal energy_update(new_value: int)

# game variable
const DEFAULT_DATA: Dictionary = {
	"day": 1,
	"energy": 100,
	"uang": 50,
	"skor_kerusakan_hutan": 0
}

var day: int = DEFAULT_DATA["day"]
var energy: int = DEFAULT_DATA["energy"]:
	set(value):
		energy = value
		energy_update.emit(energy)
		
var uang: int = DEFAULT_DATA["uang"]:
	set(value):
		uang = value
		money_update.emit(uang)
		
var skor_kerusakan_hutan: int = DEFAULT_DATA["skor_kerusakan_hutan"]

# membuat dictionary untuk setiap variable
func get_save_data() -> Dictionary:
	return {
		"day": day,
		"energy": energy,
		"uang": uang,
		"skor_kerusakan_hutan": skor_kerusakan_hutan
	}

# menyimpan variable ke user data
func save_game():
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(get_save_data(), "\t")) # "\t" agar file JSON rapi & mudah dibaca
		print("Game berhasil disimpan!")

# memasok data setiap awal game
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
			uang = parsed.get("uang", DEFAULT_DATA["uang"])
			skor_kerusakan_hutan = parsed.get("skor_kerusakan_hutan", DEFAULT_DATA["skor_kerusakan_hutan"])
			print("Data game berhasil dimuat!")
		else:
			print("Format file JSON tidak valid.")

# Merset semua data game
func reset_game():
	day = DEFAULT_DATA["day"]
	energy = DEFAULT_DATA["energy"]
	uang = DEFAULT_DATA["uang"]
	skor_kerusakan_hutan = DEFAULT_DATA["skor_kerusakan_hutan"]
	save_game()
	print("Game telah di-reset ke kondisi awal!")
	
func _ready():
	load_game()
	


#PATH/PAGE MANAGER
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

	
