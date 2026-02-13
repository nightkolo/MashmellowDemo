extends Node
class_name BlockDetector

var rays: Array[RayCast2D]
var cherry_bomb_rays: Array[RayCast2D]
var parent_block: Mashed


func is_colliding() -> bool:
	for ray: RayCast2D in rays:
		if ray.is_colliding():
			return true
	return false


func _ready() -> void:
	rays = [$Down, $Right, $Left]
	
	cherry_bomb_rays = [$CherryBombRays/Up, $CherryBombRays/Right, $CherryBombRays/Left]
	
	if get_parent() is Mashed:
		parent_block = get_parent()
		
		if parent_block.build_type == GameLogic.BuildType.RECTANGLE:
			for ray: RayCast2D in [$Right2, $Left2]:
				rays.append(ray)
				ray.visible = true
