# Game Logic
extends Node

signal player_mashed()
signal player_unmashed()
signal order_checked()
signal order_complete()

enum MashType {
	WHITE = 0,
	GOLDEN = 1,
	CHOCO = 2,
	BISCUIT = 3,
	PLAYER = 99
}

enum SpecialMashType {
	REGULAR = 0,
	CHERRY_BOMB = 1
}
enum BuildType {
	SQUARE = 0,
	RECTANGLE = 1
}

var is_checking_order_match: bool = false
var has_won: bool = false


func _ready() -> void:
	# (complete?) TODO: Move OrderCheck to player pos
	# Check Area2Ds,
	# if all mash_type(s) match,
	# emit() -> order_complete and order_checked
	# if not matching,
	# emit() -> order_checked
	player_mashed.connect(check_order_completion)

	player_unmashed.connect(check_order_completion)
	
	order_checked.connect(func():
		is_checking_order_match = false
		)
	
	order_complete.connect(func():
		GameMgr.game_just_ended.emit()
		)

func order_met() -> void:
	order_complete.emit()
	print("Game over.")
	

func check_order_completion() -> void: # Ok -> O(n), Worst case -> O(n^2)
	if GameMgr.current_order_checker == null || GameMgr.current_level.ignore_order:
		return
	
	is_checking_order_match = true
	GameMgr.current_order_checker.position = GameMgr.current_player.position
	
	await get_tree().create_timer(0.05).timeout
	
	#print("")
	if GameMgr.current_order_checker.check_satisfaction():
		#print("Hooray :D")
		order_met()
		has_won = true
		#order_complete.emit()
	#else:
		##print("Awww :(")
		#pass
		
	order_checked.emit()
	
## GameUtil

func get_mash_type_color(type: MashType) -> Color:
	var col: Color
	
	match type:
		MashType.WHITE:
			col = Color.WHITE * 1.5
			
		MashType.GOLDEN:
			col = Color.YELLOW
			
		MashType.CHOCO:
			col = Color.GRAY
			
		MashType.BISCUIT:
			col = Color.DARK_GREEN
			
		MashType.PLAYER:
			col = Color.WHITE * 3
			
	return col
			

func get_special_mash_type_color(type: SpecialMashType) -> Color:
	var col: Color
	
	#match type:
		#SpecialMashType.CHERRY_BOMB:
			#col = Color.RED * 2.0
			#
	return col


func setup_mash(sprite: Sprite2D, type: MashType, special: SpecialMashType = SpecialMashType.REGULAR) -> void:
	pass
	#if special != GameLogic.SpecialMashType.REGULAR:
		#sprite.self_modulate = get_special_mash_type_color(special)
	#else:
		#sprite.self_modulate = get_mash_type_color(type)
	
	
