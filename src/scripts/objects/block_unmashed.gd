class_name Unmashed
extends RigidBody2D

@export var mash_type: GameLogic.MashType
@export var mash_special: GameLogic.SpecialMashType
@export var build_type: GameLogic.BuildType

@onready var up: RayCast2D = $Up
@onready var sprite: Sprite2D = $Sprite2D
@onready var colli: CollisionShape2D = $CollisionShape2D

#var up_2: RayCast2D
var colli_shape: RectangleShape2D


func _ready() -> void:
	GameLogic.setup_mash(sprite, mash_type, mash_special)
	
	colli_shape = colli.shape
	#up_2 = get_node_or_null("Up2")
	


func is_mashable() -> bool:
	#if up_2:
		#return !(up.is_colliding() && up.get_collider() is Unmashed) || !(up_2.is_colliding() && up_2.get_collider() is Unmashed)
	
	return !(up.is_colliding() && up.get_collider() is Unmashed)
