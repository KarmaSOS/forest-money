extends CharacterBody2D
const HELD_ITEM_SCENE : PackedScene = preload("res://components/characters/held_item/held_item.tscn")
const SPEED = 400.0
const JUMP_VELOCITY = -400.0
const GRAVITY_MULTIPLIER: float = 1.0

@onready var hand_position: Marker2D = %hand_position
var current_item_node = null

func _ready():
	GameManager.held_update.connect(_on_held_update)

func _physics_process(delta: float) -> void:
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
