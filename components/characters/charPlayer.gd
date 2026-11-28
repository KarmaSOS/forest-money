extends CharacterBody2D
const HELD_ITEM_SCENE : PackedScene = preload("res://components/characters/held_item/held_item.tscn")
const SPEED = 400.0
const JUMP_VELOCITY = -400.0
const GRAVITY_MULTIPLIER: float = 1.0

@onready var interact_area: Area2D = %interact_area
@onready var hand_position: Marker2D = %hand_position

var trees_in_range: Array[Node2D] = []
var current_targeted_trees: Array[Node2D] = []
var current_item_node = null
var current_held_item = ""

func _ready():
	GameManager.held_update.connect(_on_held_update)
	update_target_highlights()

func _physics_process(delta: float) -> void:
	update_target_highlights()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity()*GRAVITY_MULTIPLIER * delta 

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
#	face_direction
	if direction > 0:
		$Sprite2D.flip_h = false
		hand_position.position.x = abs(hand_position.position.x)
		hand_position.scale.x = 1
	elif direction < 0:
		$Sprite2D.flip_h = true
		hand_position.position.x = -abs(hand_position.position.x)
		hand_position.scale.x = -1
		
#	Movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func _on_held_update(held_item: ItemData) -> void:
#	hapus item lama
	if current_item_node != null:
		current_item_node.queue_free()
		current_item_node = null
#	munculin item baru
	if held_item != null:
		current_item_node = HELD_ITEM_SCENE.instantiate()
		current_item_node.set_texture(held_item.icon)
		hand_position.add_child(current_item_node)
		current_held_item = held_item.id

func _on_tree_entered(body: Area2D) -> void:
	if not body in trees_in_range:
		print("append ", body)
		trees_in_range.append(body)
	
func _on_tree_exited(body: Area2D) -> void:
	trees_in_range.erase(body)
	if is_instance_valid(body) and body.has_method("apply_untargeted"):
		body.apply_untargeted()
	
func get_closest_targets(max_count: int) -> Array[Node2D]:
	
	# Bersihkan jika ada pohon yang sudah tumbang/dihapus
	trees_in_range = trees_in_range.filter(func(t): return is_instance_valid(t))
	
	# Urutkan dari yang jaraknya paling dekat ke Player
	trees_in_range.sort_custom(func(a: Node2D, b: Node2D):
		return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)
	)
	
	# Ambil sebanyak max_count (misal 1 untuk kapak, 4 untuk bensin)
	return trees_in_range.slice(0, max_count)
	
func execute_skill() -> void:
	if current_held_item.is_empty():
		return
		
	var max_target: int = ItemDatabase.get_item(current_held_item).get("stats").get("max_target", 10)
	var damage: int = ItemDatabase.get_item(current_held_item).get("stats").get("damage", 10)
	var targets := get_closest_targets(max_target)
	
	print(targets)
	
	# Terapkan efek/damage ke semua target terpilih
	for tree in targets:
		if tree.has_method("take_damage"):
			print("send damage")
			tree.take_damage(damage)
			
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("basic_attack") and current_held_item != null: # Tombol E
		execute_skill()


func update_target_highlights() -> void:
	var max_target: int = 1
	if not current_held_item.is_empty():
		max_target = ItemDatabase.get_item(current_held_item).get("stats").get("max_target", 1)
	
	# Ambil daftar target terdekat saat ini
	var new_targets := get_closest_targets(max_target)
	
	# Matikan outline pada pohon yang SUDAH BUKAN target lagi
	for old_tree in current_targeted_trees:
		if is_instance_valid(old_tree) and not old_tree in new_targets:
			if old_tree.has_method("apply_untargeted"):
				old_tree.apply_untargeted()
				
	# Nyalakan outline pada pohon yang BARU MENJADI target
	for new_tree in new_targets:
		if is_instance_valid(new_tree) and not new_tree in current_targeted_trees:
			if new_tree.has_method("apply_targeted"):
				new_tree.apply_targeted()
				
	current_targeted_trees = new_targets
