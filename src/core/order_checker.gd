## Check if all [BlockMashChecker]s are satisfied
extends Node2D
class_name OrderChecker

var order_blocks: Array[Node]

@onready var label: Label = $Label


func _ready() -> void:
	GameMgr.current_order_checker = self
	
	#order_blocks = get_children()
	
	await get_tree().create_timer(0.1).timeout
	label.text = "1-" + str(GameMgr.current_level_number)
	#modulate = Color(Color.WHITE, 0.1)


func check_satisfaction() -> bool: # Ok -> O(n), Worst case -> O(n^2)
	for block: MashBlockChecker in order_blocks:
		if !block.check_satisfaction():
			return false
			
	return true
	
