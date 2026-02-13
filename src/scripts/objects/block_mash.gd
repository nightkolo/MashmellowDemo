## Mash block in [Mashed]
extends Area2D
class_name MashBlock

var mash_type: GameLogic.MashType

var parent_block: Mashed


func _ready() -> void:
	if get_parent() is Mashed:
		parent_block = get_parent()
		
		mash_type = parent_block.mash_type


func is_match(type: GameLogic.MashType) -> bool:
	if parent_block:
		return (
			parent_block.mash_special == GameLogic.SpecialMashType.REGULAR &&
			type == mash_type
			)
		
	return 0
