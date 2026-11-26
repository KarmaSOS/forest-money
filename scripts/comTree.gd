class_name ForestTree
extends Area2D

@export_group("Textures")
@export var tex_young: Texture2D
@export var tex_old: Texture2D
@export var tex_dry: Texture2D
@export var tex_parasite: Texture2D

@onready var sprite: Sprite2D = $Sprite2D

# Variabel konfigurasi (diisi dari SceneForest sebelum add_child)
var tree_type: String = "dry"
var max_hp: int = 30
var current_hp: int = 30
var drop_item_id: String = "log_dry"
var drop_amount: int = 1
var heat_impact: float = 0.0
var damage_impact: float = 0.0


func _ready() -> void:
	_setup_tree_stats()
	current_hp = max_hp


func _setup_tree_stats() -> void:
	match tree_type:
		"young":
			if tex_young: sprite.texture = tex_young
			max_hp = 30
			drop_item_id = "log_young"
			drop_amount = 2
			heat_impact = 0.0
			damage_impact = 15.0 # Menebang pohon muda merusak ekosistem
			
		"old":
			if tex_old: sprite.texture = tex_old
			max_hp = 100
			drop_item_id = "log_old"
			drop_amount = 3
			heat_impact = 0.0
			damage_impact = -5.0 # Canopy thinning: menyehatkan hutan
			
		"dry":
			if tex_dry: sprite.texture = tex_dry
			max_hp = 20
			drop_item_id = "log_dry"
			drop_amount = 1
			heat_impact = -5.0 # Membersihkan pohon kering menurunkan risiko kebakaran
			damage_impact = 0.0
			
		"parasite":
			if tex_parasite: sprite.texture = tex_parasite
			max_hp = 120
			drop_item_id = "" # Tidak menghasilkan kayu
			drop_amount = 0
			heat_impact = -10.0
			damage_impact = -10.0


# Fungsi yang dipanggil saat pohon menerima tebasan kapak / minigame
func take_damage(amount: int) -> void:
	current_hp -= amount
	_play_hit_effect()
	
	if current_hp <= 0:
		_fell_tree()


func _play_hit_effect() -> void:
	# Efek visual sederhana: pohon sedikit bergetar & berkedip merah saat ditebang
	var tween := create_tween()
	sprite.modulate = Color(1.0, 0.4, 0.4)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)


func _fell_tree() -> void:
	# 1. Masukkan kayu ke inventory (jika ada drop)
	if not drop_item_id.is_empty() and drop_amount > 0:
		GameManager.add_item(drop_item_id, drop_amount)
		
	# 2. Terapkan dampak ekologis ke GameManager
	GameManager.forest_heat += heat_impact
	GameManager.forest_damage += damage_impact
	
	# 3. Hapus pohon dari layar
	queue_free()
