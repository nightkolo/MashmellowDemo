extends Area2D
class_name Switch

signal switch_activated(is_on: bool)

@export var door_to_interact_with: Door

var is_activated: bool



func _ready() -> void:
	body_entered.connect(func(_body: Node2D):
		interact(get_overlapping_bodies().size() > 0)
		)
	body_exited.connect(func(_body: Node2D):
		interact(get_overlapping_bodies().size() > 0)
		)


func interact(switch_on: bool = !is_activated) -> void:
	is_activated = switch_on
	door_to_interact_with.interact(switch_on)
	
	switch_activated.emit(switch_on)
	
