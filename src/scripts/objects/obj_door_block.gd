extends CollisionShape2D
class_name DoorBlock

@onready var sprite: Sprite2D = $Sprite2D

var is_activated: bool:
	get:
		return is_activated
	set(value):
		set_deferred("disabled", value)
		is_activated = value
		if value:
			sprite.self_modulate = Color(Color.WHITE, 0.5)
		else:
			sprite.self_modulate = Color(Color.WHITE, 1.0)


func _ready() -> void:
	if get_parent() is Door:
		(get_parent() as Door).door_blocks.append(self)
