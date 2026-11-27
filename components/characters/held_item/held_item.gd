extends Node2D
@onready var sprite = %Sprite2D

func set_texture(icon: Texture2D) -> void:
	if icon != null:
		if not is_node_ready():
			await ready
		sprite.texture = icon
		
		var target_size := Vector2(32, 32)
		sprite.scale = target_size / icon.get_size()
