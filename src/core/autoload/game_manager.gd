extends Node

signal game_just_ended()
signal game_end()
signal game_reset()

var current_level: Level
var current_player: Player
var current_order_checker: OrderChecker

const BLOCK_SIZE = 16.0 # Let 16.0, 64.0 Final
const MASH_WAIT_TIME = 0.5
const ORDER_COMPLETE_WAIT_TIME = 1.0

const LEVEL_FILE_BEGIN = "res://levels/level_"

const LEVEL_FILE_END = ".tscn"


func _input(event: InputEvent) -> void:
	
	
	if event.is_action_pressed("game_reset"):
		get_tree().reload_current_scene()


func _ready() -> void:
	#Engine.time_scale = 1.0/8.0
	game_just_ended.connect(func():
		await get_tree().create_timer(ORDER_COMPLETE_WAIT_TIME).timeout
		
		game_end.emit()
		)
	
	game_end.connect(goto_next_level)
		
	game_reset.connect(func():
		#GameLogic.self_destruct()
		get_tree().reload_current_scene()
		)


func goto_next_level() -> void:
	if !current_level:
		return
	
	var next_lvl_id := current_level.scene_file_path.to_int() + 1
	var next_lvl_path := LEVEL_FILE_BEGIN + str(next_lvl_id) + LEVEL_FILE_END
	
	get_tree().change_scene_to_file(next_lvl_path)
	
	#if next_lvl_id <= GameUtil.NUMBER_OF_BOARDS: 
		#Trans.slide_to_next_stage(next_lvl_path)
	#else:
		#Trans.slide_to_credits(0.4)
		#game_has_ended = true
