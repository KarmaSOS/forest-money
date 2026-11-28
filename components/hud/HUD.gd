extends Control

@onready var forest_damage := %forest_damage
@onready var forest_heat := %forest_heat
@onready var progress_damage :=%progress_damage
@onready var progress_heat := %progress_heat
@onready var day_count := %day_count


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_damage_update(GameManager.forest_damage)
	_on_heat_update(GameManager.forest_heat)
	_on_day_update(GameManager.day)
	GameManager.forest_damage_update.connect(_on_damage_update)
	GameManager.forest_heat_update.connect(_on_heat_update)
	GameManager.day_update.connect(_on_day_update)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_to_shop_pressed() -> void:
	GameManager.goto_scene("res://scenes/SceneCity.tscn")


func _on_to_sleep_pressed() -> void:
	GameManager.goto_scene("res://scenes/SceneSummary.tscn")


func _on_to_forest_pressed() -> void:
	GameManager.goto_scene("res://scenes/SceneForest.tscn")


func _on_add_money_pressed() -> void:
	GameManager.money += 10
	
func _on_damage_update(damage: int) -> void:
	progress_damage.value = damage
	forest_damage.text = "damage: " + str(damage)
	
func _on_heat_update(heat: int) -> void:
	progress_heat.value = heat
	forest_heat.text = "heat: " + str(heat)
	
func _on_day_update(day: int) -> void:
	day_count.text = "day: " + str(GameManager.day)
