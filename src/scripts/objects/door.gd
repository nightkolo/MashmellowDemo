extends StaticBody2D
class_name Door

var is_openned: bool

var colli: Array[Node]


func _ready() -> void:
	colli = get_children()


func interact(open: bool) -> void:
	is_openned = open
	
	for col: CollisionShape2D in colli:
		col.set_deferred("disabled", open)
		#col.disabled = open
