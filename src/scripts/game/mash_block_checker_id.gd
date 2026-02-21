#@tool
extends Node2D
class_name MashBlockCheckerID

@export var what_im_happy_with: Util.MashType
@export var what_im_built_like: Util.BuildType

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	GameLogic.setup_mash_block(sprite, what_im_happy_with, what_im_built_like)

	if get_parent() is Order:
		(get_parent() as Order).mash_block_checker_ids.append(self)
