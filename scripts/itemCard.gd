extends PanelContainer
class_name ItemCard

signal card_selected(item: ItemCard, item_data: ItemData)
var item_data: ItemData


var normal_style: StyleBoxFlat
var selected_style: StyleBoxFlat

@onready var icon_rect: TextureRect = $MarginContainer/VBoxContainer/image/Icon/itemIcon
@onready var type_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/type
@onready var name_label: Label = $MarginContainer/VBoxContainer/name
@onready var desc_label: RichTextLabel = $MarginContainer/VBoxContainer/desc
@onready var price_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/price

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	var base_style := get_theme_stylebox("panel")
	if base_style is StyleBoxFlat:
		normal_style = base_style.duplicate()
	else:
		normal_style = StyleBoxFlat.new()
		normal_style.set_border_width_all(2)
		normal_style.border_color = Color.TRANSPARENT

	selected_style = normal_style.duplicate()
	selected_style.border_color = Color("8293ecff")
	selected_style.set_border_width_all(2)
	
	
# signal saat panel di klik
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_selected.emit(self, item_data)
		

func set_selected(is_selected: bool) -> void:
	if is_selected:
		add_theme_stylebox_override("panel", selected_style)
	else:
		add_theme_stylebox_override("panel", normal_style)

func setup(data: ItemData) -> void:
	item_data = data
	if item_data == null:
		return

	if type_label:
		type_label.text = item_data.type.capitalize()

	if name_label:
		name_label.text = item_data.item_name

	if desc_label:
		desc_label.text = item_data.short_desc

	if price_label:
		price_label.text = "%d" % item_data.price

	if icon_rect:
		if not item_data.icon_path.is_empty() and ResourceLoader.exists(item_data.icon_path):
			icon_rect.texture = load(item_data.icon_path)
		else:
			icon_rect.texture = null
