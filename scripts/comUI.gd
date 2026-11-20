extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_to_shop_pressed() -> void:
	GameManager.goto_scene("res://scenes/SceneShop.tscn")


func _on_to_sleep_pressed() -> void:
	GameManager.goto_scene("res://scenes/SceneSummary.tscn")


func _on_to_forest_pressed() -> void:
	GameManager.goto_scene("res://scenes/SceneForest.tscn")


func _on_add_money_pressed() -> void:
	GameManager.uang += 10
