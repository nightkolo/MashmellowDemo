class_name Mashed
extends CollisionShape2D

@export var mash_type: Util.MashType
#@export var mash_special: Util.SpecialMashType
@export var build_type: Util.BuildType

@export_category("Objects to Assign")
@export var mashed_object: PackedScene = preload("res://scenes/objects/block_mashed_1x1.tscn")
@export var mashed_object_1x2: PackedScene = preload("res://scenes/objects/block_mashed_1x2.tscn")
#@export var mashed_object: PackedScene
#@export var mashed_object_1x2: PackedScene

@onready var block_detect: BlockDetector = $BlockDetect
@onready var block: MashBlock = $MashBlock

## For Anim
@onready var sprite_node: Node2D = $SpriteNode
@onready var sprite: Sprite2D = $SpriteNode/Sprite2D
@onready var sprite_eyes: Sprite2D = $Eyes/Sprite2D

var parent_player: Player
var sprite_original_pos_y: float

var _original_pos: Vector2


func is_on_ground() -> bool:
	for ray: RayCast2D in block_detect.ground_rays:
		ray.force_raycast_update()
		if ray.is_colliding():
			return true
	return false


func _ready() -> void:
	if get_parent() is Player:
		parent_player = get_parent()
		
		if parent_player.auto_assign_child_blocks:
			parent_player.child_blocks.append(self)
		
		parent_player.new_child_blocks.append(self)
	
	_original_pos = position
	sprite_original_pos_y = sprite_node.position.y
	
	GameLogic.setup_mash(sprite, mash_type, build_type)
	block.mash_type = mash_type
	
	var tween := create_tween()
	
	tween.tween_property(self, "scale", Vector2.ONE, 0.25)
	
	await get_tree().create_timer(Util.MASH_WAIT_TIME).timeout
	
	for ray: RayCast2D in block_detect.rays:
		ray.enabled = true
	
	#if mash_type == Util.MashType.CHERRY_BOMB:
	for ray: RayCast2D in block_detect.cherry_bomb_rays:
		ray.enabled = true
		

func mash() -> bool: ## Ok O(1)
	var collided: bool = false
	
	if mash_type == Util.MashType.CHERRY_BOMB:
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
				
				unmashed.queue_free()
				
				parent_player.add_child(new_mashed)
				
				await parent_player.return_position()
		
	return collided


func get_unmashed_position(found_at: Vector2, type: Util.BuildType) -> Vector2:
	var unmash_at: Vector2
	
	match type:
		
		Util.BuildType.RECTANGLE:
			if abs(found_at.y) > abs(found_at.x):
				unmash_at = Vector2(0, signf(found_at.y))
			else:
				unmash_at = Vector2(signf(found_at.x) ,minf(0, signf(found_at.y)))
		
		Util.BuildType.SQUARE:
			if abs(found_at.x) > abs(found_at.y):
				unmash_at = Vector2(signf(found_at.x), 0)
			else:
				unmash_at = Vector2(0, signf(found_at.y))
		
	return unmash_at


func get_new_mashed_positioning(found_at: Vector2, type: Util.BuildType, ray: RayCast2D = null) -> Vector2:
	var repos: Vector2
	
	match type:
		Util.BuildType.SQUARE:
			repos = position + (found_at * Util.BLOCK_SIZE)
			
			if build_type == Util.BuildType.RECTANGLE:
				repos += Vector2.DOWN * Util.BLOCK_SIZE * 0.5
				
				if ray != null:
					if ray.position.y < 0:
						repos += (Vector2.UP * Util.BLOCK_SIZE)
				
		Util.BuildType.RECTANGLE:
			repos = position + (found_at * Util.BLOCK_SIZE) + (Vector2.DOWN * Util.BLOCK_SIZE * 0.5)
	
	return repos
				

func get_mashed_object(type: Util.BuildType) -> Mashed:
	match type:
		Util.BuildType.SQUARE:
			return mashed_object.instantiate()
		Util.BuildType.RECTANGLE:
			return mashed_object_1x2.instantiate()
		_:
			return null
	

func is_attached() -> bool:
	return get_parent() is Player
