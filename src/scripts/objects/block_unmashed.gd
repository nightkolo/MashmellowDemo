class_name Unmashed
extends RigidBody2D

@export var mash_type: Util.MashType
@export var build_type: Util.BuildType

@onready var up: RayCast2D = $Up
@onready var sprite: Sprite2D = $SpriteNode/Sprite2D
@onready var colli: CollisionShape2D = $CollisionShape2D

#var up_2: RayCast2D
var colli_shape: RectangleShape2D


func _ready() -> void:
	GameLogic.setup_mash(sprite, mash_type, build_type)
	
	colli_shape = colli.shape
	


func is_mashable() -> bool:
	return !(up.is_colliding() && up.get_collider() is Unmashed)
