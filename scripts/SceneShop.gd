class_name SceneShop
extends CanvasLayer

const ITEM_CARD: PackedScene = preload("res://components/ItemCard.tscn")

@onready var btn_type_1: Button = $Panel/padding/main/Content/SIDEBAR/VBoxContainer/type
@onready var btn_type_2: Button = $Panel/padding/main/Content/SIDEBAR/VBoxContainer/type2
@onready var btn_type_3: Button = $Panel/padding/main/Content/SIDEBAR/VBoxContainer/type3
@onready var btn_close: Button = $Panel/padding/main/header/Button1
@onready var items_grid: GridContainer = $Panel/padding/main/Content/PanelContainer/MarginContainer/ITEMSLIST/Items

@export var filter_type_1: String = "all"
@export var filter_type_2: String = "tool"
@export var filter_type_3: String = "seed"

var selected_card: ItemCard = null

#ketika card dipilih
func _on_card_selected(current_card: ItemCard, item_data: ItemData) -> void:
	if selected_card == current_card:
		selected_card.set_selected(false)
		selected_card = null
		return

	if selected_card != null:
		selected_card.set_selected(false)

	selected_card = current_card
	selected_card.set_selected(true)
	

#koneksikan semua sinyal dan refresh item
func _ready() -> void:
	var grup_filter = ButtonGroup.new()
	if btn_type_1:
		btn_type_1.button_group = grup_filter
		btn_type_1.pressed.connect(_on_filter_pressed.bind(filter_type_1))
	if btn_type_2:
		btn_type_2.button_group = grup_filter
		btn_type_2.pressed.connect(_on_filter_pressed.bind(filter_type_2))
	if btn_type_3:
		btn_type_3.button_group = grup_filter
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
	if items_grid == null:
		push_warning("SceneShop2: Node 'Items' (GridContainer) tidak ditemukan.")
		return

	# bersihkan grid
	for child in items_grid.get_children():
		child.queue_free()

	# ambil daftar item dari db (all/type)
	var items: Array[ItemData] = []
	if item_type.is_empty() or item_type == "all":
		items = ItemDatabase.get_all_items()
	else:
		items = ItemDatabase.get_items_by_type(item_type)

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
