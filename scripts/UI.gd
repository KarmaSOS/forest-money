extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_to_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/SceneShop.tscn")


func _on_to_sleep_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/SceneSummary.tscn")


func _on_to_forest_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/SceneForest.tscn")
