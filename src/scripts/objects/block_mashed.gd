class_name Mashed
extends CollisionShape2D

@export var mash_type: GameLogic.MashType
@export var mash_special: GameLogic.SpecialMashType
@export var build_type: GameLogic.BuildType

@export_category("Objects to Assign")
#@export var mashed_object: PackedScene = load("res://scenes/block_mashed.tscn")
#@export var mashed_object_1x2: PackedScene = load("res://scenes/block_mashed_1x2.tscn")
@export var mashed_object: PackedScene
@export var mashed_object_1x2: PackedScene

@onready var block_detect: BlockDetector = $BlockDetect
@onready var area_2d: Area2D = $Area2D
@onready var sprite: Sprite2D = $Icon
@onready var block: MashBlock = $Area2D

var parent_player: Player

var _original_pos: Vector2


func _ready() -> void:
	if get_parent() is Player:
		parent_player = get_parent()
		
		if parent_player.auto_assign_child_blocks:
			parent_player.child_blocks.append(self)
		
		parent_player.new_child_blocks.append(self)
	
	_original_pos = position
	#colli_shape = shape
	
	GameLogic.setup_mash(sprite, mash_type, mash_special)
	block.mash_type = mash_type
	
	var tween := create_tween()
	
	tween.tween_property(self, "scale", Vector2.ONE, 0.25)
	
	await get_tree().create_timer(GameMgr.MASH_WAIT_TIME).timeout
	
	for ray: RayCast2D in block_detect.rays:
		ray.enabled = true
	
	for ray: RayCast2D in block_detect.cherry_bomb_rays:
		ray.enabled = true
		

func mash() -> bool: ## Ok O(1)
	var collided: bool = false
	
	if mash_special == GameLogic.SpecialMashType.CHERRY_BOMB:
		return false
	
	for ray: RayCast2D in block_detect.rays:
		ray.force_raycast_update()
		
		if (ray.is_colliding() && ray.get_collider() is Unmashed):
			var unmashed: Unmashed = ray.get_collider()
			
			if unmashed.is_mashable():
				parent_player.has_mashed.emit()
				collided = true
				
				var pos: Vector2 = unmashed.global_position - global_position
				var unmash_at: Vector2 = get_unmashed_position(pos, unmashed.build_type)
				var new_mashed: Mashed = get_mashed_object(unmashed.build_type)

				new_mashed.position = get_new_mashed_positioning(unmash_at, unmashed.build_type, ray)
				new_mashed.mash_type = unmashed.mash_type
				new_mashed.mash_special = unmashed.mash_special
				#
				unmashed.queue_free()
				#
				parent_player.add_child(new_mashed)
				#
				await parent_player.return_position()
		
	return collided


func get_unmashed_position(found_at: Vector2, type: GameLogic.BuildType) -> Vector2:
	var unmash_at: Vector2
	
	match type:
		
		GameLogic.BuildType.RECTANGLE:
			if abs(found_at.y) > abs(found_at.x):
				unmash_at = Vector2(0, signf(found_at.y))
			else:
				unmash_at = Vector2(signf(found_at.x) ,minf(0, signf(found_at.y)))
		
		GameLogic.BuildType.SQUARE:
			if abs(found_at.x) > abs(found_at.y):
				unmash_at = Vector2(signf(found_at.x), 0)
			else:
				unmash_at = Vector2(0, signf(found_at.y))
		
	return unmash_at


func get_new_mashed_positioning(found_at: Vector2, type: GameLogic.BuildType, ray: RayCast2D = null) -> Vector2:
	var repos: Vector2
	
	match type:
		GameLogic.BuildType.SQUARE:
			repos = position + (found_at * GameMgr.BLOCK_SIZE)
			
			if build_type == GameLogic.BuildType.RECTANGLE:
				repos += Vector2.DOWN * 8.0
				
				if ray != null:
					if ray.position.y < 0:
						repos += (Vector2.UP * GameMgr.BLOCK_SIZE)
				
		GameLogic.BuildType.RECTANGLE:
			repos = position + (found_at * GameMgr.BLOCK_SIZE) + (Vector2.DOWN * 8.0)
	
	return repos
				

func get_mashed_object(type: GameLogic.BuildType) -> Mashed:
	match type:
		GameLogic.BuildType.SQUARE:
			return mashed_object.instantiate()
			
		GameLogic.BuildType.RECTANGLE:
			return mashed_object_1x2.instantiate()
			
		_:
			return null
	

func is_attached() -> bool:
	return get_parent() is Player
