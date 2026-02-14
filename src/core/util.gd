extends Node
class_name Util

enum MashType {
	WHITE = 0,
	GOLDEN = 1,
	CHOCO = 2,
	BISCUIT = 3,
	PLAYER = 99
}

enum SpecialMashType {
	REGULAR = 0,
	CHERRY_BOMB = 1
}
enum BuildType {
	SQUARE = 0,
	RECTANGLE = 1
}

const BLOCK_SIZE = 64.0
const GRAVITY_MULT = 4.0

static func get_mash_type_texture(type: MashType, build: BuildType) -> Texture2D:
	var text: Texture2D
	
	match type:
		MashType.WHITE:
			if build ==	BuildType.RECTANGLE:
				text = preload("res://assets/objects/block-white-1x2-01.png")
			else:
				text = preload("res://assets/objects/block-white-01.png")
			
		MashType.GOLDEN:
			if build ==	BuildType.RECTANGLE:
				text = preload("res://assets/objects/block-golden-1x2-01.png")
			else:
				text = preload("res://assets/objects/block-golden-01.png")
			
		MashType.CHOCO:
			if build ==	BuildType.RECTANGLE:
				text = preload("res://assets/objects/block-choco-1x2-01.png")
			else:
				text = preload("res://assets/objects/block-choco-01.png")
			
		MashType.BISCUIT:
			if build ==	BuildType.RECTANGLE:
				text = preload("res://assets/objects/block-biscuit-1x2-01.png")
			else:
				text = preload("res://assets/objects/block-biscuit-01.png")
			
		MashType.PLAYER:
			text = preload("res://assets/objects/block-player-01.png")
			
	return text


static func get_mash_type_color(type: Util.MashType, build: Util.BuildType) -> Color:
	var col: Color
	
	match type:
		Util.MashType.WHITE:
			col = Color.WHITE * 1.5
			
		Util.MashType.GOLDEN:
			col = Color.YELLOW
			
		Util.MashType.CHOCO:
			col = Color.GRAY
			
		Util.MashType.BISCUIT:
			col = Color.DARK_GREEN
			
		Util.MashType.PLAYER:
			col = Color.WHITE * 3
			
	return col
