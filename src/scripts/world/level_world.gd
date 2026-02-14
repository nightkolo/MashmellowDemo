@tool
extends Node2D
class_name World

@export var bg_color: Color = Color(1.0, 1.0, 0.56)
#@export var tile_color: Color = Color(1.0, 1.0, 0.45)
@export var bg_speed: float = 4.0

@onready var bg_sprite: Sprite2D = $BG/Sprite2D




func _ready() -> void:
	bg_sprite.self_modulate = bg_color


func _process(delta: float) -> void:
	bg_sprite.position -= Vector2.ONE * bg_speed * 10.0 * delta
	
	if bg_sprite.position.x < -360.0:
		bg_sprite.position = Vector2.ZERO
