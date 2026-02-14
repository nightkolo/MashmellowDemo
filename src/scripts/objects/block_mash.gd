## Mash block in [Mashed]
extends Area2D
class_name MashBlock

var mash_type: Util.MashType

var parent_block: Mashed


func _ready() -> void:
	collision_layer = 4
	collision_mask = 4
	
	if get_parent() is Mashed:
		parent_block = get_parent()
		
		mash_type = parent_block.mash_type


func is_match(type: Util.MashType) -> bool:
	if parent_block:
		return (
			parent_block.mash_special == Util.SpecialMashType.REGULAR &&
			type == mash_type
			)
		
	return 0
