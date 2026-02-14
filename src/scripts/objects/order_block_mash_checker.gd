## Checks a single [MashBlock] in [Mashed] 
extends Area2D
class_name MashBlockChecker

@export var what_im_happy_with: Util.MashType

@onready var sprite: Sprite2D = $Icon


func _ready() -> void:
	GameLogic.setup_mash(sprite, what_im_happy_with)
	
	collision_layer = 2048
	collision_mask = 2048
	
	
# Called by parent OrderChecker
func check_satisfaction() -> bool: # Ok -> O(1), worst case -> O(n)
	var value: bool = false
	var areas: Array[Area2D] = get_overlapping_areas()

	if areas.size() == 1 && areas[0] is MashBlock:
		value = (areas[0] as MashBlock).is_match(what_im_happy_with)
	
	return value
