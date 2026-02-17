## Checks a single [MashBlock] in [Mashed] 
extends Area2D
class_name MashBlockChecker

@export var what_im_happy_with: Util.MashType

#@onready var sprite: Sprite2D = $Icon
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	GameLogic.setup_mash_block(sprite, what_im_happy_with)
	
	if get_parent() is OrderChecker:
		(get_parent() as OrderChecker).order_blocks.append(self)
	
	collision_layer = 4
	collision_mask = 4
	
	
# Called by parent OrderChecker
func check_satisfaction() -> bool: # Ok -> O(1), worst case -> O(n)
	var value: bool = false
	var areas: Array[Area2D] = get_overlapping_areas()

	print("")
	print_debug(self)
	print_debug(what_im_happy_with)
	print_debug(areas)

	if areas.size() == 1 && areas[0] is MashBlock:
		print_debug((areas[0] as MashBlock).mash_type)
		
		value = (areas[0] as MashBlock).is_match(what_im_happy_with)
	
	print_debug(value)
	
	return value
