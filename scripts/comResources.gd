@tool
extends PanelContainer

@export_enum("uang", "energy", "log") var tipe_resource: String = "uang"

@export var icon_texture: Texture2D:
	set(value):
		icon_texture = value
		if is_node_ready():
			$MARGIN/CONTAINER/Icon.texture = value

@export var preview_amount: int = 0:
	set(value):
		preview_amount = value
		if is_node_ready():
			_update_text(value)

func _ready() -> void:
	if icon_texture:
		$MARGIN/CONTAINER/Icon.texture = icon_texture
	_update_text(preview_amount)
		
	if Engine.is_editor_hint():
		return
		
	match tipe_resource:
		"uang":
			_update_text(GameManager.money)
			GameManager.money_update.connect(_update_text)
		"energy":
			_update_text(GameManager.energy)
			GameManager.energy_update.connect(_update_text)
		"log":
			_update_text(GameManager.get_item_count("log"))
			GameManager.inventory_update.connect(func(id, amount):
				if id == "log":
					_update_text(amount)
			)

func _update_text(nilai: int) -> void:
	$MARGIN/CONTAINER/Amount.text = str(nilai)
