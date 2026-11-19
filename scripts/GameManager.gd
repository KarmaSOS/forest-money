extends Node

# game variable
var day = 1
var stamina = 100
var uang = 50
var skor_kerusakan_hutan = 0

# membuat dictionary untuk setiap variable
func get_save_data() -> Dictionary:
	return {
		"day": day,
		"stamina": stamina,
		"uang": uang,
		"skor_kerusakan_hutan": skor_kerusakan_hutan
	}

# menyimpan variable ke user data
func save_game():
	var file_path = "user://savegame.json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)

	if file:
		var data = get_save_data()
		# Ubah Dictionary jadi teks format JSON, lalu tulis ke file
		var json_string = JSON.stringify(data)
		file.store_string(json_string)
		print("Game berhasil disimpan!")

# memasok data setiap awal game
func load_game():
	
	var file_path = "user://savegame.json"
	# CEK
	if not FileAccess.file_exists(file_path):
		print("Belum ada file save, pakai data default.")
		return
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(json_text)
		
		if error == OK:
			var data = json.get_data()
		# Masukkan kembali data dari file JSON ke variabel game
			day = data.get("day", 1)
			stamina = data.get("stamina", 100)
			uang = data.get("uang", 50)
			skor_kerusakan_hutan = data.get("skor_kerusakan_hutan", 0)
			print("Data game berhasil dimuat!")
		else:
			print("Gagal membaca file JSON.")

# Merset semua data game
func reset_game():
	day = 1
	stamina = 100
	uang = 50
	skor_kerusakan_hutan = 0

	save_game()
	print("Game telah di-reset ke kondisi awal!")
	
func _ready():
	load_game()
	
func _process(delta: float) -> void:
	pass
