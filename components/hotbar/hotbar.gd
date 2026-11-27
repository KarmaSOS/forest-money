@tool
extends Control


@export var slot_scene: PackedScene:
	set(value):
		slot_scene = value
		_rebuild_slots()
@export_range(1, 20, 1) var slot_count: int = 5:
	set(value):
		slot_count = max(1, value)
		_rebuild_slots()

@onready var container := get_node_or_null("%slot_container") as HBoxContainer
@onready var slots:= container.get_children()

var selected_index: int = -1

func _ready() -> void:
	GameManager.inventory_update.connect(_rebuild_slots.unbind(2))
	_rebuild_slots()

func _rebuild_slots() -> void:
	if container == null:
		return
	if slot_scene == null:
		return
	
#	bersihkan slots
	slots.clear()
	for child in container.get_children():
		if Engine.is_editor_hint():
			child.free()
		else:
			child.queue_free()

#	ambil item dari inventory
	var items: Array = []
	if not Engine.is_editor_hint() and is_inside_tree():
		items = GameManager.get_inventory_items()

#	bikin slot dan load item
	for i in range(slot_count):
		var slot_instance := slot_scene.instantiate()
		slot_instance.slot_hovered.connect(_on_slot_hovered)
		slot_instance.slot_unhovered.connect(_on_slot_unhovered)
		slot_instance.slot_selected.connect(_on_slot_selected)
		
		slot_instance.slot_index = i
		container.add_child(slot_instance)
		slots.append(slot_instance)

		if not Engine.is_editor_hint() and i < items.size() and items[i] is ItemData:
			var icon: Texture2D = items[i].get("icon")	
			slot_instance.set_icon(icon)
			
	if selected_index >= 0 and selected_index < slots.size():
		slots[selected_index].apply_select()

func _on_slot_hovered(index: int) -> void:
	slots[index].apply_hover()

func _on_slot_unhovered(index: int) -> void:
	if index != selected_index:
		slots[index].apply_unhover()
	else:
		slots[index].apply_select()

func _on_slot_selected(index: int) -> void:
	if slot_count <= 0:
		return
	slots[selected_index].apply_unhover()

	if index == selected_index:
		selected_index = -1
		return
	
	selected_index = index
	slots[selected_index].apply_select()
	_sync_held_item_to_game_manager()

func _sync_held_item_to_game_manager() -> void:
	if Engine.is_editor_hint() : return
		
	var items: Array = GameManager.get_inventory_items()
	
	if selected_index >= 0 and selected_index < items.size() and items[selected_index] is ItemData:
		GameManager.held_item = items[selected_index]
	else: GameManager.held_item = null
		

	
	
	
