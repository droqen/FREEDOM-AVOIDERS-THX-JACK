@tool
extends Node2D
@export var vessel : NavdiVessel
func _ready() -> void:
	if not Engine.is_editor_hint():
		hide()
		queue_free() # bye
func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint() and visible:
		position = Vector2.ZERO
		queue_redraw()
func _draw() -> void:
	var vessel_room_size := vessel.vessel_room_size
	if Engine.is_editor_hint():
		var linecolour := Color.WHITE
		var linewidth := -1
		var viewport_2d := EditorInterface.get_editor_viewport_2d()
		var view_transform := viewport_2d.global_canvas_transform
		var view_size := viewport_2d.size
		var world_pos_0 := view_transform.affine_inverse() * Vector2(0,0)
		var world_pos_1 := view_transform.affine_inverse() * Vector2(view_size)
		#draw_line(world_pos_0, world_pos_1, Color.WHITE)
		if vessel_room_size.x >= 10:
			for x in range(
			ceil(world_pos_0.x/vessel_room_size.x)*vessel_room_size.x,
			floor(world_pos_1.x/vessel_room_size.x)*vessel_room_size.x+1,
			vessel_room_size.x):
				draw_line(Vector2(x,world_pos_0.y), Vector2(x,world_pos_1.y), linecolour, linewidth)
		if vessel_room_size.y >= 10:
			for y in range(
			ceil(world_pos_0.y/vessel_room_size.y)*vessel_room_size.y,
			floor(world_pos_1.y/vessel_room_size.y)*vessel_room_size.y+1,
			vessel_room_size.y):
				draw_line(Vector2(world_pos_0.x,y), Vector2(world_pos_1.x,y), linecolour, linewidth)
		#if vessel_room_size.x >= 10 and vessel_room_size.y >= 10:
			#for x in range(
			#ceil(world_pos_0.x/vessel_room_size.x)*vessel_room_size.x,
			#floor(world_pos_1.x/vessel_room_size.x)*vessel_room_size.x+1,
			#vessel_room_size.x):
				#for y in range(
				#ceil(world_pos_0.y/vessel_room_size.y)*vessel_room_size.y,
				#floor(world_pos_1.y/vessel_room_size.y)*vessel_room_size.y+1,
				#vessel_room_size.y):
					#draw_string(
					#preload(
						#"res://fonts/88_shortvariation.tres"
					#),
					#Vector2(world_pos_0.x,world_pos_0.y),
					#"%d,%d"%[x,y]
					#)
				#
