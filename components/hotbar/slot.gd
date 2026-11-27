@tool
extends PanelContainer
signal slot_hovered(index: int)
signal slot_unhovered(index: int)
signal slot_selected(index: int)

@onready var icon_rect = %icon
@onready var container = $"."
@onready var style = container.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
var slot_index: int = -1

func set_icon(icon: Texture2D) -> void:
	if icon == null:
		return
	icon_rect.texture = icon

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		slot_selected.emit(slot_index)
		
func _on_mouse_entered() -> void:
	slot_hovered.emit(slot_index)

func _on_mouse_exited() -> void:
	slot_unhovered.emit(slot_index)

func apply_select() -> void:
	style.border_color = Color.GREEN
	style.set_border_width_all(2)
	container.add_theme_stylebox_override("panel", style)
	#print("slot: ", slot_index, " sellect")
	
func apply_hover() -> void:
	style.set_border_width_all(2)
	style.border_color = Color.BLUE
	container.add_theme_stylebox_override("panel", style)
	#print("slot: ", slot_index, " hover")

func apply_unhover() -> void:
	style.set_border_width_all(1)
	style.border_color = Color.WHITE
	container.add_theme_stylebox_override("panel", style)
	#print("slot: ", slot_index, " unhover")
