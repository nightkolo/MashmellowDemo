## Under construction
class_name Player
extends CharacterBody2D

signal has_mashed()
signal has_jumpped()
signal has_landed(strength: float)
signal cherry_bomb_activated()

@export var animate: bool = true ## @experimental
@export var auto_assign_child_blocks: bool = true
#@export var unmashed_object: PackedScene
#@export var unmashed_object_1x2: PackedScene 
@export_group("Movement Variables")
@export_range(-600.0, 600.0, 1.0, "or_greater", "or_less") var speed: float = 480.0
@export_range(-1500.0, 1500.0, 1.0, "or_greater", "or_less") var acceleration: float = 1000.0
@export_range(-2000.0, 2500.0, 1.0, "or_greater", "or_less") var deceleration: float = 2000.0
@export_range(-400.0, 400.0, 1.0, "or_greater", "or_less") var jump_height: float = 1050.0
@export_category("Objects to Assign")
@export var unmashed_object: PackedScene = preload("res://scenes/objects/block_unmashed_1x1.tscn")
@export var unmashed_object_1x2: PackedScene = preload("res://scenes/objects/block_unmashed_1x2.tscn")

@onready var jump_window_timer: Timer = $JumpBufferTimer
@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
@onready var cherry_bomb_air_timer: Timer = $CherryBombAirTimer
@onready var mashed: Mashed = $Mashed

var stop_deceleration: float = deceleration * 4.0
var air_deceleration: float = deceleration / 3.2
var input_direction: float

var child_blocks: Array[Mashed] # Stack data structure
var new_child_blocks: Array[Mashed] # Stack data structure

var is_landed: bool

const CHERRY_BOMB_STRENGTH = 400.0

var _pos_before_mash: Vector2
var _has_mashed: bool
var _last_velocity_y: float = 0.0


func _ready() -> void:
	GameMgr.current_player = self
	
	has_landed.connect(anim_land)
	has_jumpped.connect(anim_jump)
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


func get_unmashed_object(type: Util.BuildType) -> Unmashed:
	match type:
		Util.BuildType.SQUARE:
			return unmashed_object.instantiate()
		Util.BuildType.RECTANGLE:
			return unmashed_object_1x2.instantiate()
		_:
			return null
			

func mash_child_blocks() -> void: ## Ok -> O(n)
	if child_blocks[-1].mash_type == Util.MashType.CHERRY_BOMB:
		return
	
	var blocks: Array[Mashed] = child_blocks.duplicate(true) # To avoid infinite recursion
	_pos_before_mash = position
	
	for block: Mashed in blocks:
		block.mash()


func unmash() -> void: ## Ok -> O(1)
	if !can_unmash():
		return
	
	GameLogic.player_unmashed.emit()
	
	var old_mashed: Mashed = child_blocks.pop_back()
	_pos_before_mash = position
	
	match old_mashed.mash_type:
		Util.MashType.CHERRY_BOMB:
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
			
		_:
			var unmashed: Unmashed = get_unmashed_object(old_mashed.build_type)
					
			unmashed.global_position = old_mashed.global_position
			unmashed.mash_type = old_mashed.mash_type
			old_mashed.queue_free()
			
			GameMgr.current_level.add_child(unmashed)
			
			await return_position()


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
	
	_last_velocity_y = velocity.y
	
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


func _state() -> void:
	#print(can_mash())
	if !is_landed && is_on_floor():
		has_landed.emit(abs(_last_velocity_y / 100.0))
		is_landed = true
		
	if !is_on_floor():
		is_landed = false
		
	if is_on_ceiling() && _tween_jump:
		_tween_jump.kill()
		
		for block: Mashed in child_blocks:
			block.sprite.scale = Vector2.ONE * 0.5


func _animate() -> void:
	for block: Mashed in child_blocks:
		block.sprite_eyes.position = velocity / 50.0


func _physics_process(delta: float) -> void:
	if !GameLogic.is_checking_order_match:
		_move(delta)
	_state()
	_animate()


### Anim
var _tween_land: Tween

func anim_land(strength: float = 1.0) -> void:
	if !animate:
		return
	
	var mag: float = minf(strength / 50.0, 0.3)
	
	if _tween_land:
		_tween_land.kill()
	
	_tween_land = get_tree().create_tween().set_parallel()
	_tween_land.set_ease(Tween.EASE_OUT)
	
	for block: Mashed in child_blocks:
		var ori: float = block.sprite_original_pos_y
		
		block.sprite_node.position.y = ori
		
		if block.is_on_ground():
			_tween_land.tween_property(block.sprite_node,"scale",Vector2(1.0 + mag,1.0 - mag),0.07)
			_tween_land.tween_property(block.sprite_node,"scale",Vector2(1.0,1.0),1.0).set_trans(Tween.TRANS_ELASTIC).set_delay(0.07)
		else:
			_tween_land.tween_property(block.sprite_node,"position:y",ori + (mag * 50.0),0.07)
			_tween_land.tween_property(block.sprite_node,"position:y",ori,1.0).set_trans(Tween.TRANS_ELASTIC).set_delay(0.07)


var _tween_jump: Tween

func anim_jump() -> void:
	if !animate:
		return
	
	if _tween_jump:
		_tween_jump.kill()
		
	_tween_jump = get_tree().create_tween().set_parallel()
	
	_tween_jump.set_ease(Tween.EASE_OUT)
	
	for block: Mashed in child_blocks:
		if block.is_on_ground():
			_tween_jump.tween_property(block.sprite, "scale", Vector2(0.875, 1.25) * 0.5, 0.1)
			_tween_jump.tween_property(block.sprite, "scale", Vector2.ONE * 0.5, 0.6).set_trans(Tween.TRANS_SINE).set_delay(0.1)
		else:
			_tween_jump.tween_property(block.sprite, "scale", Vector2.ONE*0.5, 1.0)



func _check_child_blocks() -> void:
	if new_child_blocks.is_empty():
		return
	
	# TODO: Fix for 1x2 blocks
	# There's issues probably
	
	for i in range(1, new_child_blocks.size()):
		if new_child_blocks[i].position == new_child_blocks[0].position:
			new_child_blocks[i].queue_free()
			child_blocks.pop_back()
			
	new_child_blocks.clear()
	_has_mashed = false
