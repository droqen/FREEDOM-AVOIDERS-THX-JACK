@tool
extends SheetSprite
class_name SheetRegionSprite

@export var subregion : Rect2i = Rect2i(0,0,5,5)

func _physics_process(_delta: float) -> void:
	if playing:
		ani_subindex += 1
	
	if sheet and frames:
		texture = sheet.texture
		#hframes = sheet.hframes
		#vframes = sheet.vframes
		hframes = 1
		vframes = 1
		if playing and ani_subindex >= ani_period:
			ani_subindex -= ani_period
			ani_index += 1
		ani_index = posmod(ani_index, len(frames))
		var f : int = frames[ani_index]
		@warning_ignore("integer_division")
		var fc := Vector2i(
			f % sheet.hframes,
			f / sheet.hframes,
		)
		region_enabled = true # hello
		region_rect = Rect2(
			Vector2(10 * fc + subregion.position),
			subregion.size,
		)
		#offset = Vector2(subregion.position)
