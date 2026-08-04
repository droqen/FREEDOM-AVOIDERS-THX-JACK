@tool
extends Sprite2D
class_name SheetSprite

@export var sheet : Sheet = null
@export var playing : bool = false
@export var frames : PackedInt32Array = [0, 1]
@export var ani_period : int = 8
@export var ani_index : int = 0
var ani_subindex : int = 0
var frame_offset : int = 0

func _try_change(newframes : PackedInt32Array = [], newperiod : int = -1) -> bool:
	var changed : bool = false
	if !newframes.is_empty() and newframes != frames:
		frames = newframes
		ani_index = 0
		ani_subindex = 0
		changed = true
	if newperiod >= 0 and newperiod != ani_period:
		ani_period = newperiod
		ani_subindex = 0
		changed = true
	playing = (ani_period > 0 and len(frames) > 1)
	return changed

func setup(newframes : PackedInt32Array = [], newperiod : int = -1):
	if frame_offset: for i in len(newframes): newframes[i] += frame_offset
	_try_change(newframes, newperiod)
	return self

func setup_forcechangeindex(newframes : PackedInt32Array = [], newperiod : int = -1,
	change_frame_to_ani_index_dict : Dictionary = {}):
	if frame_offset:
		for i in len(newframes): newframes[i] += frame_offset
		for k in change_frame_to_ani_index_dict:
			change_frame_to_ani_index_dict[k+frame_offset] = change_frame_to_ani_index_dict[k]+frame_offset
	var next_ani : int = change_frame_to_ani_index_dict.get(frame, -1)
	if next_ani >= 0:
		pass
	elif newframes[0] != frame:
		next_ani = 0
	elif len(newframes)>1:
		for i in range(1, len(newframes)):
			if newframes[i] != frame:
				next_ani = i
	
	if next_ani >= 0:
		if _try_change(newframes, newperiod):
			ani_index = next_ani
			frame = frames[ani_index]
	return self

func setup_trywaitformatch(newframes : PackedInt32Array = [], newperiod : int = -1,
	frames_to_match : PackedInt32Array = []):
	if frame_offset:
		for i in len(newframes): newframes[i] += frame_offset
		for i in len(frames_to_match): frames_to_match[i] += frame_offset
	if !frames_to_match: frames_to_match = [newframes[0]]
	if frame in frames_to_match:
		_try_change(newframes, newperiod)
	else:
		var will_match : bool = false
		for f in frames:
			if f in frames_to_match:
				will_match = true
				break # if i will match in future, then wait for it
		if !will_match:
			_try_change(newframes, newperiod)
	return self

func _ready():
	playing = not Engine.is_editor_hint()

func _get_configuration_warnings() -> PackedStringArray:
	return ["Do not leave a sheetsprite playing in edit mode"] if playing else []

func _physics_process(_delta: float) -> void:
	if playing:
		ani_subindex += 1
	
	if sheet and frames:
		texture = sheet.texture
		hframes = sheet.hframes
		vframes = sheet.vframes
		if playing and ani_subindex >= ani_period:
			ani_subindex -= ani_period
			ani_index += 1
		ani_index = posmod(ani_index, len(frames))
		frame = frames[ani_index]
