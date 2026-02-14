# Game Logic
extends Node

signal player_mashed()
signal player_unmashed()
signal order_checked()
signal order_complete()



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
	
	
func setup_mash(
	sprite: Sprite2D,
	type: Util.MashType,
	special: Util.SpecialMashType = Util.SpecialMashType.REGULAR,
	build: Util.BuildType = Util.BuildType.SQUARE) -> void:
	if special != Util.SpecialMashType.REGULAR:
		sprite.texture = preload("res://assets/objects/block-cherry-bomb-01.png")
	else:
		sprite.texture = Util.get_mash_type_texture(type, build)
	
	
