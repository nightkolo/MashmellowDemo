# Game Logic
extends Node

signal player_mashed()
signal player_unmashed()
signal order_checked()
signal order_complete()

var is_checking_order_match: bool = false
var has_won: bool = false

var _order_check_ori_pos: Vector2


func reset_game_logic() -> void:
	await get_tree().create_timer(0.1).timeout
	
	_order_check_ori_pos = GameMgr.current_order_checker.position


func _ready() -> void:
	player_mashed.connect(check_order_completion)

	player_unmashed.connect(check_order_completion)
	
	order_checked.connect(func():
		is_checking_order_match = false
		
		GameMgr.current_order_checker.global_position = _order_check_ori_pos
		)
	
	order_complete.connect(func():
		GameMgr.game_just_ended.emit()
		)
	
	await get_tree().create_timer(0.1).timeout
	
	if GameMgr.current_order_checker:
		_order_check_ori_pos = GameMgr.current_order_checker.global_position


func order_met() -> void:
	order_complete.emit()
	print("Game over.")
		

func check_order_completion() -> void: # Ok -> O(n), Worst case -> O(n^2)
	if GameMgr.current_order_checker == null || GameMgr.current_level.ignore_order:
		return
	
	is_checking_order_match = true
	GameMgr.current_order_checker.global_position = GameMgr.current_player.position
	
	await get_tree().create_timer(0.05).timeout
	
	print("Checking..")
	if GameMgr.current_order_checker.check_satisfaction():
		order_met()
		has_won = true
		
	order_checked.emit()
	
	
func setup_mash_block(sprite: Sprite2D, type: Util.MashType, build: Util.BuildType = Util.BuildType.SQUARE) -> void:
	sprite.texture = Util.get_block_mash_type_texture(type, build)
	

func setup_mash(
	sprite: Sprite2D,
	type: Util.MashType,
	build: Util.BuildType = Util.BuildType.SQUARE) -> void:
	sprite.texture = Util.get_mash_type_texture(type, build)
	
	
