extends Node2D
const TREE: PackedScene = preload("uid://b3ibniindnkp")
@onready var spawn_start = %spawnStart.position.x
@onready var spawn_end = %spawnEnd.position.x
@onready var ground = %spawnStart.position.y
@onready var forest = %Forest



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("luas: ", spawn_end - spawn_start, " hektare")
	var cur_spawn = spawn_start
	while cur_spawn <= spawn_end:
		var tree := TREE.instantiate()
		var t = randi_range(0, 2)
		if t == 0:
			tree.tree_type = "young"
		if t == 1:
			tree.tree_type = "old"
		if t == 2:
			tree.tree_type = "dry"
		
		
		var position = Vector2(cur_spawn+ randf_range(-40,40), ground)
		var scale_y = randf_range(6.0, 8.0)
		var scale_x = randf_range(6.0, 6.5)
		
		tree.position = position
		tree.scale = Vector2(scale_x, scale_y)
		if randf() > 0.7: tree.scale.x *= -1
		forest.add_child(tree)
		cur_spawn += 200
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func spawn_teees() -> void:
	pass
