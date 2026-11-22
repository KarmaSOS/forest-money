extends Node2D

signal interact_requested(merchant: Node)

@export var idle_texture: Texture2D
@export var nearby_texture: Texture2D
@export var scene_shop: SceneShop

@onready var sprite: Sprite2D = $Sprite2D
@onready var hint_button: Button = $Interact
var is_nearby: bool = false

func _ready() -> void:
	scene_shop.hide()
	_set_nearby(false)

func _unhandled_input(event: InputEvent) -> void:
	if not is_nearby:
		return
	if event.is_action_pressed("interact"):
		_on_interact_pressed()
		get_viewport().set_input_as_handled()
		

func _on_body_entered(body: Node2D) -> void:
	if not _is_player(body):
		return
	_set_nearby(true)

func _on_body_exited(body: Node2D) -> void:
	if not _is_player(body):
		return
	_set_nearby(false)
	
#kirim_sinyal_interaksi
func _on_interact_pressed() -> void:
	if not is_nearby:
		return
	scene_shop.open_shop()
	interact_requested.emit(self)

#cek_player(opsional)
func _is_player(body: Node2D) -> bool:
	return body.is_in_group("player") or body.name == "Player"

#merchant_reaction
func _set_nearby(active: bool) -> void:
	is_nearby = active
	hint_button.visible = active
	if active and nearby_texture != null:
		sprite.texture = nearby_texture
	elif not active and idle_texture != null:
		sprite.texture = idle_texture
