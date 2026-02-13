## Under construction
class_name Player
extends CharacterBody2D

signal has_mashed()
signal has_jumpped()
signal cherry_bomb_activated()

@export var auto_assign_child_blocks: bool = true
#@export var unmashed_object: PackedScene = preload("res://scenes/block_unmashed.tscn")
#@export var unmashed_object_1x2: PackedScene = preload("res://scenes/block_unmashed_1x2.tscn")
@export var unmashed_object: PackedScene
@export var unmashed_object_1x2: PackedScene 
@export_group("Movement Variables")
@export_range(-400.0, 400.0, 1.0, "or_greater", "or_less") var speed: float = 120.0
@export_range(-1000.0, 1000.0, 1.0, "or_greater", "or_less") var acceleration: float = 250.0
@export_range(-2000.0, 2000.0, 1.0, "or_greater", "or_less") var deceleration: float = 400.0
@export_range(-400.0, 400.0, 1.0, "or_greater", "or_less") var jump_height: float = 242.0

@onready var jump_window_timer: Timer = $JumpBufferTimer
@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
@onready var cherry_bomb_air_timer: Timer = $CherryBombAirTimer

var stop_deceleration: float = deceleration * 4.0
var air_deceleration: float = deceleration / 3.2
var input_direction: float

var child_blocks: Array[Mashed] # Stack data structure
var new_child_blocks: Array[Mashed] # Stack data structure

const CHERRY_BOMB_STRENGTH = 400.0

var _pos_before_mash: Vector2
var _has_mashed: bool


func _ready() -> void:
	GameMgr.current_player = self
	
	has_mashed.connect(func():
		if !_has_mashed:
			GameLogic.player_mashed.emit()
			_has_mashed = true
		
		await get_tree().create_timer(0.025).timeout
		
		_check_child_blocks()
		)
	cherry_bomb_activated.connect(func():
		cherry_bomb_air_timer.start()
		)
		
	new_child_blocks.clear()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_mash"):
		mash_child_blocks()
	
	if event.is_action_pressed("move_unmash"):
		unmash()


func get_unmashed_object(type: GameLogic.BuildType) -> Unmashed:
	match type:
		GameLogic.BuildType.SQUARE:
			return unmashed_object.instantiate()
		GameLogic.BuildType.RECTANGLE:
			return unmashed_object_1x2.instantiate()
		_:
			return null
			

func mash_child_blocks() -> void: ## Ok -> O(n)
	if child_blocks[-1].mash_special == GameLogic.SpecialMashType.CHERRY_BOMB:
		return
	
	#var blocks: Array[Mashed] = child_blocks.duplicate(true)
	_pos_before_mash = position
	
	for block: Mashed in child_blocks:
		block.mash()


func unmash() -> void: ## Ok -> O(1)
	if !can_unmash():
		return
	
	GameLogic.player_unmashed.emit()
	
	var mashed: Mashed = child_blocks.pop_back()
	_pos_before_mash = position
	
	match mashed.mash_special:
		
		GameLogic.SpecialMashType.REGULAR:
			var unmashed: Unmashed = get_unmashed_object(mashed.build_type)
					
			unmashed.global_position = mashed.global_position
			unmashed.mash_type = mashed.mash_type
			unmashed.mash_special = mashed.mash_special
			mashed.queue_free()
			
			GameMgr.current_level.add_child(unmashed)
			
			await return_position()
			
		GameLogic.SpecialMashType.CHERRY_BOMB:
			cherry_bomb_activated.emit()
			
			var push_to: Vector2
			
			for ray: RayCast2D in mashed.block_detect.cherry_bomb_rays:
				ray.force_raycast_update()
				
				if ray.get_collider() is Player:
					push_to = -ray.target_position.sign()
			
			if push_to.y > push_to.x && velocity.y > 0:
				velocity.y = 0.0
				
			velocity += -push_to * CHERRY_BOMB_STRENGTH
			
			mashed.queue_free()


func is_being_flown() -> bool:
	return cherry_bomb_air_timer.time_left > 0.0


func can_mash() -> bool:
	for block: Mashed in child_blocks:
		if block.block_detect.is_colliding():
			return true
	return false
	
		
func can_unmash() -> bool:
	return child_blocks.size() > 1 && is_on_floor()


func return_position() -> void:
	await get_tree().create_timer(0.01).timeout
	
	position = _pos_before_mash


func jump() -> void:
	has_jumpped.emit()
	
	velocity.y = -jump_height


func _move(delta: float) -> void:
	var was_on_floor: bool = is_on_floor()
	
	#print(velocity)
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

	if was_on_floor && !is_on_floor() && velocity.y >= 0.0:
		coyote_jump_timer.start()

	# Variable jump height, coyote jump, and jump buffer
	if Input.is_action_just_pressed("move_jump"):
		if coyote_jump_timer.time_left > 0.0:
			jump()
		else:
			jump_window_timer.start()
		
	# If the player in on the floor and within the jump window/jump buffer timer, then jump
	if is_on_floor() && !jump_window_timer.is_stopped():
		jump()
	
	if Input.is_action_just_released("move_jump") and velocity.y < 0.0:
		velocity.y = velocity.y / 2.0
	

	# Horizontal movement with acceleration
	input_direction = Input.get_axis("move_left", "move_right")

	if input_direction != 0:
		#sprite.flip_h = input_direction < 0
		velocity.x = move_toward(velocity.x, input_direction * speed, acceleration * delta)
	else:
		if is_being_flown():
			velocity.x = move_toward(velocity.x, 0, air_deceleration * delta)
			
			if is_on_floor():
				cherry_bomb_air_timer.stop()
		else:
			velocity.x = move_toward(velocity.x, 0, deceleration * delta)
			
	if input_direction < 0 && velocity.x > 0.0:
		velocity.x = move_toward(velocity.x, 0.0, stop_deceleration * delta)

	if input_direction > 0 && velocity.x < 0.0:
		velocity.x = move_toward(velocity.x, 0.0, stop_deceleration * delta)


## TODO: Highlighting for unmashable blocks
var but_is_unmashable: bool = false


func _state() -> void:
	#print(can_mash())
	pass


func _animate() -> void:
	pass


func _physics_process(delta: float) -> void:
	if !GameLogic.is_checking_order_match:
		_move(delta)
	_state()
	_animate()
	

func _check_child_blocks() -> void:
	if new_child_blocks.is_empty():
		return
	
	# TODO: Fix for 1x2 blocks
	
	for i in range(1, new_child_blocks.size()):
		if new_child_blocks[i].position == new_child_blocks[0].position:
			new_child_blocks[i].queue_free()
			child_blocks.pop_back()
			
	new_child_blocks.clear()
	_has_mashed = false
