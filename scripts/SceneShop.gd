class_name SceneShop
extends CanvasLayer

const ITEM_CARD: PackedScene = preload("res://components/ItemCard.tscn")
@onready var btn_types: Array[Button] = [%type_all, %type_tools, %type_material]
@onready var btn_close: Button = %close_shop
@onready var items_grid: GridContainer = %items
@onready var spinbox_quantity: SpinBox = %quantity
@onready var quantity_field: LineEdit = spinbox_quantity.get_line_edit()
var quantity: int = 1

@export var types: Array[String]= ["all", "tool", "material"]

@export var success_message: PanelContainer
@export var fail_message: PanelContainer

@onready var btn_buy: Button = %buy
@onready var btn_sell: Button = %sell
@onready var label_total_price: Label = %total_price
var total_price: int = 0
var buying: bool = true

var selected_card: ItemCard = null
var selected_item: ItemData = null

#ketika card dipilih
func _on_card_selected(current_card: ItemCard, item_data: ItemData) -> void:
	if selected_card == current_card:
		reset_shop()
		return
		
	if selected_card != null:
		selected_card.set_selected(false)
		
	reset_shop()
	selected_card = current_card
	selected_item = item_data
	selected_card.set_selected(true)
	spinbox_quantity.editable=true
	count_total_price()
	
#koneksikan semua sinyal dan refresh item
func _ready() -> void:
	quantity_field.text_changed.connect(_on_quantity_text_changed)
	quantity_field.placeholder_text = "1"
	
	spinbox_quantity.editable = false
	
	var count: int = mini(btn_types.size(), types.size())
	for i in range(count):
		btn_types[i].pressed.connect(_on_filter_pressed.bind(types[i]))

	btn_close.pressed.connect(_on_close_pressed)

	_refresh_items(types[0])

func open_shop() -> void:
	show()
	_refresh_items("all")
#
func _on_filter_pressed(item_type: String) -> void:
	_refresh_items(item_type)


func _on_close_pressed() -> void:
	hide()


func _refresh_items(item_type: String) -> void:
	selected_card = null
	selected_item = null
	spinbox_quantity.editable = false
	
	if items_grid == null:
		push_warning("SceneShop2: Node 'Items' (GridContainer) tidak ditemukan.")
		return

	# bersihkan grid
	for child in items_grid.get_children():
		child.queue_free()

	# ambil daftar item dari db 
	var items: Array[ItemData] = []
	if buying:
		if item_type.is_empty() or item_type == "all":
			items = ItemDatabase.get_all_items()
		else:
			items = ItemDatabase.get_items_by_type(item_type)
	else:
		items = GameManager.get_inventory_items(item_type)

	# generate card
	for item in items:
		#check instance 
		if ITEM_CARD == null:
			push_warning("SceneShop2: ITEM_CARD belum di-preload")
			return
		
#		generate item
		var card := ITEM_CARD.instantiate()
		items_grid.add_child(card)

		if card.has_method("setup"):
			card.setup(item, buying)

		if card.has_signal("card_selected"):
			card.card_selected.connect(_on_card_selected)


func _on_buy_pressed() -> void:
	if selected_item == null:
		print("no item selected")
		return
		
	if GameManager.buy_item(selected_item.id, quantity):
		print("Berhasil membeli: ", selected_item.item_name)
		success_message.show()
		reset_shop()
		
	else:
		fail_message.show()
	
	count_total_price()
		
	


func _on_success_pressed() -> void:
	success_message.hide()


func _on_fail_pressed() -> void:
	fail_message.hide()


func _on_buy_display_pressed() -> void:
	buying = true
	btn_sell.hide()
	btn_buy.show()
	reset_shop()
	_refresh_items(types[0])


func _on_sell_display_pressed() -> void:
	buying = false
	btn_buy.hide()
	btn_sell.show()
	reset_shop()
	_refresh_items(types[0])


func _on_sell_pressed() -> void:
	if selected_item == null:
		return
		
	if GameManager.sell_item(selected_item.id, quantity):
		print("Berhasil Menjual: ", selected_item.item_name)
		success_message.show()
		reset_shop()
	else:
		fail_message.show()
		pass



func count_total_price() -> void:
	print("recount")
	if selected_card == null:
		return
	total_price = quantity * selected_item.price
	
	if buying and total_price > GameManager.money:
		label_total_price.add_theme_color_override("font_color", Color.RED)
	elif not buying and GameManager.get_item_count(selected_item.id) < quantity:
			label_total_price.add_theme_color_override("font_color", Color.RED)
	else:
		label_total_price.add_theme_color_override("font_color", Color.GREEN)
	
	if total_price <= 0 or quantity <= 0:
		label_total_price.add_theme_color_override("font_color", Color.RED)
		
	label_total_price.text = str(total_price)
	
	
func _on_quantity_text_changed(value: String) -> void:
	print("text changed")
	if value.is_valid_int():
		quantity = int(value)
	else: 
		quantity = 0
	count_total_price()

func _on_quantity_value_changed(value: float) -> void:
	quantity = int(value)
	count_total_price()
	
func reset_shop() -> void:
	if selected_card: selected_card.set_selected(false)
	selected_card = null
	selected_item = null
	quantity_field.text = ""
	quantity_field.placeholder_text = "1"
	quantity = 1
	spinbox_quantity.value = 1
	spinbox_quantity.editable=true
	total_price = 0
	label_total_price.text = "0"
	
