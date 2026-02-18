extends Node2D
class_name BlockDetector

@onready var ground_rays: Array[RayCast2D] = [$DownRays/Down, $DownRays/Down2]
@onready var rays: Array[RayCast2D] = [$Down, $Right, $Left]
@onready var cherry_bomb_rays: Array[RayCast2D] = [$CherryBombRays/Up, $CherryBombRays/Right, $CherryBombRays/Left]
#@onready var cherry_bomb_rays: Array[Area2D] = [$CherryBombRays/Up2, $CherryBombRays/Right2, $CherryBombRays/Left2]


var parent_block: Mashed


func is_colliding() -> bool:
	for ray: RayCast2D in rays:
		if ray.is_colliding():
			return true
	return false


func _ready() -> void:
	#rays = [$Down, $Right, $Left]
	#
	#cherry_bomb_rays = [$CherryBombRays/Up, $CherryBombRays/Right, $CherryBombRays/Left]
	#
	#ground_rays = [$DownRays/Down, $DownRays/Down2]
	
	if get_parent() is Mashed:
		parent_block = get_parent()
		
		if parent_block.build_type == Util.BuildType.RECTANGLE:
			for ray: RayCast2D in [$Right2, $Left2]:
				rays.append(ray)
				ray.visible = true
