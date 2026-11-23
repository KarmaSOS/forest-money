class_name SceneShop
extends CanvasLayer

const ITEM_CARD: PackedScene = preload("res://components/ItemCard.tscn")

@onready var btn_type_1: Button = %type_all
@onready var btn_type_2: Button = %type_tools
@onready var btn_type_3: Button = %type_material
@onready var btn_close: Button = %close_shop
@onready var items_grid: GridContainer = %items
@onready var amount_field: SpinBox = %amount
@onready var amount: int = 0

@export var filter_type_1: String = "all"
@export var filter_type_2: String = "tool"
@export var filter_type_3: String = "material"

@export var success_message: PanelContainer
@export var fail_message: PanelContainer

@onready var buying: bool = true
@onready var btn_buy: Button = %buy
@onready var btn_sell: Button = %sell
@onready var label_total_price: Label = %total_price
var total_price: int = 0

var selected_card: ItemCard = null
var selected_item: ItemData = null

#ketika card dipilih
func _on_card_selected(current_card: ItemCard, item_data: ItemData) -> void:
	if selected_card == current_card:
		selected_card.set_selected(false)
		selected_card = null
		selected_item = null
		return
		
	if selected_card != null:
		selected_card.set_selected(false)
		
	selected_card = current_card
	selected_item = item_data
	selected_card.set_selected(true)
	amount_field.editable=true
	count_total_price()
	
#koneksikan semua sinyal dan refresh item
func _ready() -> void:
	var line_edit: LineEdit = amount_field.get_line_edit()
	line_edit.text_changed.connect(_on_amount_text_changed)
	
	amount_field.editable = false
	
	if btn_type_1:
		btn_type_1.pressed.connect(_on_filter_pressed.bind(filter_type_1))
	if btn_type_2:
		btn_type_2.pressed.connect(_on_filter_pressed.bind(filter_type_2))
	if btn_type_3:
		btn_type_3.pressed.connect(_on_filter_pressed.bind(filter_type_3))
	if btn_close:
		btn_close.pressed.connect(_on_close_pressed)

	_refresh_items(filter_type_1)

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
	amount_field.editable = false
	
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
			card.setup(item)

		if card.has_signal("card_selected"):
			card.card_selected.connect(_on_card_selected)


func _on_buy_pressed() -> void:
	if selected_item == null:
		return
		
	if GameManager.buy_item(selected_item.id, amount):
		print("Berhasil membeli: ", selected_item.item_name)
		success_message.show()
	else:
		fail_message.show()
		pass


func _on_success_pressed() -> void:
	success_message.hide()


func _on_fail_pressed() -> void:
	fail_message.hide()


func _on_buy_display_pressed() -> void:
	buying = true
	btn_sell.hide()
	btn_buy.show()
	_refresh_items(filter_type_1)


func _on_sell_display_pressed() -> void:
	buying = false
	amount = 0
	amount_field.value=0
	amount_field.editable=false
	label_total_price.text = "0"
	btn_buy.hide()
	btn_sell.show()
	_refresh_items(filter_type_1)


func _on_sell_pressed() -> void:
	if selected_item == null:
		return
		
	if GameManager.sell_item(selected_item.id, amount):
		print("Berhasil Menjual: ", selected_item.item_name)
		success_message.show()
	else:
		fail_message.show()
		pass



func count_total_price() -> void:
	if selected_card == null:
		return
	total_price = amount * selected_item.price
	if  total_price > GameManager.money and buying:
		label_total_price.add_theme_color_override("font_color", Color.RED)
	else:
		label_total_price.add_theme_color_override("font_color", Color.GREEN)
	
	label_total_price.text = str(total_price)
	
	
func _on_amount_text_changed(value: String) -> void:
	print("text changed")
	if value.is_valid_int():
		amount = int(value)
	else: 
		amount = 0
	count_total_price()

func _on_amount_value_changed(value: float) -> void:
	amount = int(value)
	count_total_price()
