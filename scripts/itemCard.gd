extends PanelContainer
class_name ItemCard

signal card_selected(item: ItemCard, item_data: ItemData)
var item_data: ItemData
var is_selected: bool = false

var normal_style: StyleBoxFlat
var selected_style: StyleBoxFlat
var hover_style: StyleBoxFlat

@onready var icon_rect: TextureRect = %itemIcon
@onready var type_label: Label = %item_type
@onready var name_label: Label = %item_name
@onready var desc_label: RichTextLabel = %item_description
@onready var price_label: Label = %item_price
@onready var stock_label: Label  = %stock

func _ready() -> void:
	GameManager.stock_update.connect(func(item_id, value):
		if item_id == item_data.id:
			_update_stock(value)
	)
	GameManager.inventory_update.connect(func(item_id, value):
		if item_id == item_data.id:
			_update_stock(value)
	)
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
	
	hover_style = normal_style.duplicate()
	hover_style.border_color = Color("ffffffff")
	hover_style.set_border_width_all(2)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_selected.emit(self, item_data)

func set_selected(yes: bool) -> void:
	if yes:
		is_selected = true
		add_theme_stylebox_override("panel", selected_style)
	else:
		is_selected = false
		add_theme_stylebox_override("panel", normal_style)

func setup(data: ItemData, buying: bool) -> void:
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
		price_label.text = "C " + "%d" % item_data.price

	if icon_rect:
		if not item_data.icon_path.is_empty() and ResourceLoader.exists(item_data.icon_path):
			icon_rect.texture = load(item_data.icon_path)
		else:
			icon_rect.texture = null
	
	if stock_label:
		if buying:
			stock_label.text = str(GameManager.get_stock(item_data.id))
		else: 
			stock_label.text = str(GameManager.get_item_count(item_data.id))

func _on_mouse_entered() -> void:
	add_theme_stylebox_override("panel", hover_style)

func _on_mouse_exited() -> void:
	if not is_selected:
		add_theme_stylebox_override("panel", normal_style)

func _update_stock(nilai: int) -> void:
	stock_label.text = str(nilai)
