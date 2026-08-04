@tool

extends Node2D
class_name NavdiBodyMover

@export var use_internal_subpixels : bool = false
var subpixel_position : Vector2 = Vector2.ZERO

#enum { HORIZONTAL, VERTICAL, } # axes already default godot consts!

func _enter_tree() -> void:
	if Engine.is_editor_hint() and get_child_count() < 1:
		var shape := RectangleShape2D.new()
		shape.size = Vector2(7.9, 7.9)
		var shapecast := ShapeCast2D.new()
		shapecast.name = 'solidcast'
		shapecast.enabled = false
		shapecast.target_position = Vector2(0,0)
		shapecast.shape = shape
		await get_tree().process_frame
		if is_inside_tree():
			add_child(shapecast)
			shapecast.owner = owner if owner else self

func cast_best_snap_dir(body : Node2D, caster : ShapeCast2D, axis, movement_amount : float) -> int:
	var scoreStay = cast_fraction(body,caster,axis,movement_amount,0)
	if scoreStay >= 1: return 0
	var scoreMinus = cast_fraction(body,caster,axis,movement_amount,-1)
	var scorePlus = cast_fraction(body,caster,axis,movement_amount,1)
	
	var other_axis = HORIZONTAL if (axis==VERTICAL) else VERTICAL
	if scoreMinus>0 and cast_fraction(body,caster,other_axis,-1)<1:scoreMinus=0
	if scorePlus >0 and cast_fraction(body,caster,other_axis, 1)<1:scorePlus =0
	
	if scoreMinus > scoreStay:
		if scoreMinus > scorePlus: return -1
		elif scorePlus > scoreMinus: return 1
		else: return (-1) if randf()<0.5 else (1)
	elif scorePlus > scoreStay:
		return 1
	else:
		return 0

func cast_fraction(body : Node2D, caster : ShapeCast2D, axis, movement_amount : float, snap_dir : int = 0) -> float:
	caster.position = Vector2.ZERO
	caster.target_position = Vector2.ZERO
	match axis:
		HORIZONTAL:
			caster.target_position.x = movement_amount
			caster.position.y += snapp_rel(body.position.y, snap_dir)
		VERTICAL:
			caster.target_position.y = movement_amount
			caster.position.x += snapp_rel(body.position.x, snap_dir)
	caster.force_shapecast_update()
	var fraction : float = caster.get_closest_collision_safe_fraction()
	if fraction <= 0.001: return 0
	if fraction >= 0.999: return 1
	return fraction

func round_away_from_0(v:float) -> int:
	if v > 0: return floor(v)
	else: return ceil(v)

func move(body : Node2D, axis, movement_amount : float = 0.0, snap_dir : int = 0):
	match axis:
		HORIZONTAL:
			if use_internal_subpixels:
				var x : int = round(body.position.x)
				subpixel_position.x += body.position.x - x
				body.position.x = x
				if sign(subpixel_position.x) == sign(movement_amount):
					subpixel_position.x += movement_amount
				else:
					# reset to 0, then add movement amount
					subpixel_position.x = movement_amount
				var dx : int = round_away_from_0(subpixel_position.x)
				if dx:
					body.position.x += dx
					subpixel_position.x -= dx
			else:
				body.position.x += movement_amount
			if snap_dir: body.position.y = snapp(body.position.y, snap_dir)
		VERTICAL:
			if use_internal_subpixels:
				var y : int = round(body.position.y)
				subpixel_position.y += body.position.y - y
				body.position.y = y
				if sign(subpixel_position.y) == sign(movement_amount):
					subpixel_position.y += movement_amount
				else:
					# reset to 0, then add movement amount
					subpixel_position.y = movement_amount
				var dy : int = round_away_from_0(subpixel_position.y)
				if dy:
					body.position.y += dy
					subpixel_position.y -= dy
			else:
				body.position.y += movement_amount
			if snap_dir: body.position.x = snapp(body.position.x, snap_dir)

func try_slip_move(body : Node2D, caster : ShapeCast2D, axis, movement_amount : float, slip_mask : int = 0) -> bool:
	body.position -= Vector2(
		1 if (axis == HORIZONTAL) else 0,
		1 if (axis == VERTICAL) else 0
	) * sign(movement_amount)
	movement_amount += sign(movement_amount)
	
	var snap_dir = cast_best_snap_dir(body, caster, axis, movement_amount)
	if snap_dir * slip_mask < 0: snap_dir = 0
	var fraction = cast_fraction(body, caster, axis, movement_amount, snap_dir)
	if fraction > 0.001:
		if fraction < 1.0:
			movement_amount *= fraction
		move(body, axis, movement_amount, snap_dir)
	elif use_internal_subpixels:
		move(body, axis, 0, 0)
	return fraction >= 1.0
	
func try_move(body : Node2D, caster : ShapeCast2D, axis, movement_amount : float) -> bool:
	body.position -= Vector2(
		1 if (axis == HORIZONTAL) else 0,
		1 if (axis == VERTICAL) else 0
	) * sign(movement_amount)
	movement_amount += sign(movement_amount)
	
	var snap_dir = 0#cast_best_snap_dir(body, caster, axis, movement_amount)
	var fraction = cast_fraction(body, caster, axis, movement_amount, snap_dir)
	if fraction > 0.001:
		if fraction < 1.0:
			movement_amount *= fraction
		move(body, axis, movement_amount, snap_dir)
	elif use_internal_subpixels:
		move(body, axis, 0, 0)
	return fraction >= 1.0

func snapp(value : float, snap_dir : int) -> float:
	return value + snap_dir
	#if snap_dir == 0: return value
	#if value != roundf(value):
		#if snap_dir < 0: snap_dir += 1; value = floori(value)
		#if snap_dir > 0: snap_dir -= 1; value = ceili(value)
	#return value + snap_dir

func snapp_rel(value : float, snap_dir : int) -> float:
	return snapp(value, snap_dir) - value
