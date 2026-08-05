extends Node2D

var ROOMWIDTH : int = 12
var ROOMHEIGHT : int = 7
var cell_gems : Array = []
enum { FRESH_GEM, GEM, EMPTY, DELETED_GEM, }
var cell_statuses : Array = []
enum {
	ON,
	PENDING,
	OFF,
}
@onready var skater = $skater
@onready var maze : Maze = $Maze_Collisions
@onready var gemmaze : Maze = $Maze_Gems

var timer : int = 0

func _ready() -> void:
	for y in ROOMHEIGHT: for x in ROOMWIDTH:
		match maze.get_cell_tid(Vector2i(x*2,y*2)):
			4: cell_statuses.append(ON)
			_: cell_statuses.append(OFF)
		cell_gems.append(EMPTY)
	_render()
func _physics_process(_delta: float) -> void:
	var gx : int = round((skater.position.x - 15) / 20.0)
	var gy : int = round((skater.position.y - 15) / 20.0)
	print(gx,", ",gy)
	var gxypos := Vector2(gx*20+15, gy*20+15)
	var disttogxypos = gxypos.distance_to(skater.position)
	if disttogxypos < 5:
		var i: = gx+gy*ROOMWIDTH
		if cell_gems[i] in [FRESH_GEM, GEM]:
			cell_gems[i] = EMPTY
			print("ding")
	
	if timer <= 5:
		if timer == 1:
			# first step - spawn pending
			cell_statuses = cell_statuses.map(func(s):
				match s:
					ON: return ON
					PENDING: return PENDING
					OFF: return PENDING if randf() < 0.25 else OFF
			)
		elif timer == 5:
			# clean up gems
			cell_gems = cell_gems.map(func(g):
				match g:
					FRESH_GEM : return GEM
					DELETED_GEM : return EMPTY
					_: return g
			)
	elif timer >= 100 or Pin.get_action_hit():
		for i in len(cell_gems):
			match cell_statuses[i]:
				ON: cell_gems[i] = FRESH_GEM # todo: animate these ones
				PENDING: cell_gems[i] = DELETED_GEM
				OFF: pass # no effect on gems
		cell_statuses = cell_statuses.map(func(s):
			match s:
				ON: return OFF
				PENDING: return ON
				OFF: return OFF
		)
		timer = 0
	timer += 1
	_render()
func _render() -> void:
	#gemmaze.clear()
	var i : int = 0
	var t : int = floor(timer * 0.1)
	for y in ROOMHEIGHT: for x in ROOMWIDTH:
		match [cell_statuses[i],t]:
		#match maze.get_cell_tid(Vector2i(x*2,y*2)):
			[ON,0]: _rot(x,y,40+timer%3)
			[ON,_]: _rot(x,y,4)
			[PENDING,4]: _rot(x,y,30)
			[PENDING,6]: _rot(x,y,31)
			[PENDING,8]: _rot(x,y,32)
			[PENDING,_]: _rot(x,y,3)
			[OFF,_]: _rot(x,y,-1)
		match cell_gems[i]:
			FRESH_GEM: _rog(x,y,50+timer)
			DELETED_GEM: _rog(x,y,-1)
			GEM: _rog(x,y,51+t%2)
			EMPTY: _rog(x,y,-1)
		i += 1

# [r]ender [o]ne [t]ile
func _rot(x:int, y:int, tid:int) -> void:
	for a in [
		[0,0, 0,],
		[1,0, 3,],
		[1,1, 2,],
		[0,1, 1,],
	]:
		maze.set_cell_tid_transformed(Vector2i(x*2+a[0],y*2+a[1]),tid,a[2])
# [r]ender [o]ne [g]em
func _rog(x:int, y:int, tid:int) -> void:
	gemmaze.set_cell_tid(Vector2i(x*2,y*2),tid)
