@tool
extends Node2D
class_name NavdiVessel
@export var vessel_room_size : Vector2i = Vector2i(100, 100)
func _enter_tree() -> void:
	if Engine.is_editor_hint():
		var grid = load("res://navdi/navdivesselgrid.gd").new()
		grid.vessel = self
		add_child(grid, false, Node.INTERNAL_MODE_BACK)

var exiled_maze : Maze
var exiles_by_name : Dictionary
var exiles_by_roomcoords : Dictionary

func _ready() -> void:
	if !Engine.is_editor_hint():
		for child in get_children():
			add_exile(child)
			remove_child(child)
func add_exile(x:Node) -> void:
	if x:
		exiles_by_name[x.name] = x
		if x is Maze:
			if exiled_maze == null:
				exiled_maze = x
			else:
				push_warning("Can't exile multiple mazes! Skipping maze %s" % x.name)
		elif x is Node2D:
			@warning_ignore("integer_division")
			var roomcoords : Vector2i = (x as Node2D).position as Vector2i / vessel_room_size
			var a : Array = exiles_by_roomcoords.get(roomcoords, []) as Array
			a.append(x)
			exiles_by_roomcoords.set(roomcoords, a)
		elif x is Control:
			@warning_ignore("integer_division")
			var roomcoords : Vector2i = (x as Control).position as Vector2i / vessel_room_size
			var a : Array = exiles_by_roomcoords.get(roomcoords, []) as Array
			a.append(x)
			exiles_by_roomcoords.set(roomcoords, a)
	else:
		push_warning("Can't add null exile")
func get_maze() -> Maze:
	return exiled_maze
func get_exile_by_name(exile_name : String) -> Node:
	return exiles_by_name.get(exile_name, null) as Node
func spawn_exile_by_name(exile_name : String, parent : Node) -> Node:
	var exile : Node = get_exile_by_name(exile_name)
	if exile:
		var new_owner = parent.owner if parent.owner else parent
		var x = exile.duplicate()
		parent.add_child(x)
		x.owner = new_owner
		return x
	else:
		return null
func get_exiles_by_roomcoords(roomcoords : Vector2i) -> Array:
	return exiles_by_roomcoords.get(roomcoords, []) as Array
func spawn_exiles_by_roomcoords(roomcoords : Vector2i, parent : Node, wipe_existing_children : bool = true) -> void:
	if wipe_existing_children:
		for child in parent.get_children():
			child.queue_free() # bye
			#parent.remove_child(child) # byeee
	var exiles : Array = get_exiles_by_roomcoords(roomcoords)
	if exiles:
		var offset : Vector2 = -roomcoords*vessel_room_size
		var new_owner = parent.owner if parent.owner else parent
		for x0 in exiles:
			var x = (x0 as Node).duplicate()
			x.position += offset
			parent.add_child(x)
			x.owner = new_owner
