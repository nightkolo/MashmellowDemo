## Check if all [BlockMashChecker]s are satisfied
extends Node2D
class_name OrderChecker

var order_blocks: Array[Node]


func _ready() -> void:
	visible = false
	
	GameMgr.current_order_checker = self


func check_satisfaction() -> bool: # Ok -> O(n), Worst case -> O(n^2)
	for block: MashBlockChecker in order_blocks:
		if !block.check_satisfaction():
			return false
			
	return true
	
