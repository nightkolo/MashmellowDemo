@tool
extends Node2D
class_name MashBlockCheckerID

@onready var sprite: Sprite2D = $Sprite2D


@export var what_im_happy_with: Util.MashType:
	set(value):
		$Sprite2D.texture = Util.get_block_mash_type_texture(value, what_im_built_like)
		what_im_happy_with = value
@export var what_im_built_like: Util.BuildType:
	set(value):
		$Sprite2D.texture = Util.get_block_mash_type_texture(what_im_happy_with, value)
		what_im_built_like = value



func _ready() -> void:
	GameLogic.setup_mash_block(sprite, what_im_happy_with, what_im_built_like)

	if get_parent() is Order:
		(get_parent() as Order).mash_block_checker_ids.append(self)
