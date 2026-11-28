class_name ForestTree
extends Area2D

@export_group("Textures")
@export var tex_young: Texture2D
@export var tex_old: Texture2D
@export var tex_dry: Texture2D
@export var tex_parasite: Texture2D
@onready var sprite: Sprite2D = %Sprite2D
@onready var hit_particles: GPUParticles2D = %HitParticle
@onready var hit_particles2: = %HitParticle2
var hit_tween: Tween
var is_felled: bool = false

# Variabel konfigurasi (diisi dari SceneForest sebelum add_child)
var tree_type: String = "dry"
var max_hp: int = 30
var current_hp: int = 30
var drop_item_id: String = "log"
var drop_amount: int = 1
var heat_impact: float = 0.0
var damage_impact: float = 0.0
var hp: int = 20


func _ready() -> void:
	_setup_tree_stats()
	current_hp = max_hp
	if sprite.material:
		sprite.material = sprite.material.duplicate() # Otomatis unik per pohon
		sprite.material.set_shader_parameter("active", false)


func _setup_tree_stats() -> void:
	match tree_type:
		"young":
			if tex_young: sprite.texture = tex_young
			max_hp = 30
			drop_item_id = "log"
			drop_amount = 2
			heat_impact = 0.0
			damage_impact = 15.0 # Menebang pohon muda merusak ekosistem
			
		"old":
			if tex_old: sprite.texture = tex_old
			max_hp = 100
			drop_item_id = "log"
			drop_amount = 3
			heat_impact = 0.0
			damage_impact = -5.0 # Canopy thinning: menyehatkan hutan
			
		"dry":
			if tex_dry: sprite.texture = tex_dry
			max_hp = 20
			drop_item_id = "log"
			drop_amount = 1
			heat_impact = -5.0 # Membersihkan pohon kering menurunkan risiko kebakaran
			damage_impact = 0.0
			
		"parasite":
			if tex_parasite: sprite.texture = tex_parasite
			max_hp = 120
			drop_item_id = "log" # Tidak menghasilkan kayu
			drop_amount = 0
			heat_impact = -10.0
			damage_impact = -10.0


func take_damage(amount: int) -> void:
	if is_felled: return
	current_hp -= amount
	_play_hit_effect()
	
	if current_hp <= 0:
		_fell_tree()


func _play_hit_effect() -> void:
	if hit_particles:
		hit_particles.emitting = true
	if hit_particles2:
		hit_particles2.restart()
		hit_particles2.emitting = true
		
	if hit_tween:
		hit_tween.kill()
		
	if sprite.material is ShaderMaterial:
		hit_tween = create_tween()
		sprite.material.set_shader_parameter("hit_tint", Color(1.0, 0.3, 0.3))
		hit_tween.tween_method(
			func(c: Color): sprite.material.set_shader_parameter("hit_tint", c),
			Color(1.0, 0.3, 0.3),
			Color.WHITE,
			0.15
		)


func _fell_tree() -> void:
	is_felled = true
	
	# 1. Masukkan kayu & dampak ekologis
	if not drop_item_id.is_empty() and drop_amount > 0:
		GameManager.add_item(drop_item_id, drop_amount)
	GameManager.forest_heat += heat_impact
	GameManager.forest_damage += damage_impact
	
	# 2. Matikan deteksi Area2D supaya outline target langsung hilang & tidak bisa dipukul lagi
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	# 3. Tunggu sebentar (0.15 detik) agar kilatan merah pada sprite sempat terlihat!
	await get_tree().create_timer(0.15).timeout
	
	# 4. Sembunyikan gambar pohon (seolah sudah tumbang), TAPI biarkan partikelnya tetap jalan
	sprite.visible = false
	
	# 5. Tunggu hingga sisa partikel selesai jatuh & menghilang (sesuai Lifetime partikel)
	await get_tree().create_timer(1.0).timeout
	
	# 6. Baru hapus node pohon dari memori secara permanen
	queue_free()
	
func apply_targeted() -> void:
	print("Material saat ini: ", sprite.material)
	if sprite.material is ShaderMaterial:
		sprite.material.set_shader_parameter("active", true)

func apply_untargeted() -> void:
	if sprite.material is ShaderMaterial:
		sprite.material.set_shader_parameter("active", false)
