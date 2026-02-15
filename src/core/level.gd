extends Node2D
class_name Level

#@export_group("Dev options")
@export var show_dev_ui: bool = false ## @experimental
@export var ignore_order: bool = false


func _ready() -> void:
	GameMgr.current_level_number = scene_file_path.to_int()
	
	GameMgr.current_level = self
