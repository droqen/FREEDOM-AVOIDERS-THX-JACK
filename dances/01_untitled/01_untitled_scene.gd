extends Node2D

var phase : int = 150

@onready var killmaze : Maze = $KillMaze

func getcubepos(pos) -> Vector2i:
	var cell : Vector2i = killmaze.local_to_map(pos - killmaze.position)
	var cubecell = Vector2i(
		cell.x - cell.x % 2,
		cell.y - cell.y % 2,
	)
	return cubecell

func settidcube(cell,tid,tidafter=-1,delay=0) -> void:
	var rottable : bool = false
	#if tid in [4, 6, 46]: rottable = false
	if cell.x % 2 == 0 and cell.y % 2 == 0:
		killmaze.set_cell_tid(cell, tid)
		cell.x += 1
		killmaze.set_cell_tid_transformed(cell, tid, 3 if rottable else 0)
		cell.y += 1
		killmaze.set_cell_tid_transformed(cell, tid, 2 if rottable else 0)
		cell.x -= 1
		killmaze.set_cell_tid_transformed(cell, tid, 1 if rottable else 0)
		if delay > 0:
			cell.y -= 1
			await get_tree().create_timer(delay/60.0).timeout
			if is_inside_tree() and killmaze:
				# is it still the tid it was when i left it?
				if killmaze.get_cell_tid(cell) == tid:
					settidcube(cell, tidafter)
	else:
		pass

func _ready() -> void:
	for cell in killmaze.get_used_cells():
		match killmaze.get_cell_tid(cell):
			3: settidcube(cell, 3)
			6: settidcube(cell, 9)
			_: settidcube(cell, -1)

func _physics_process(_delta: float) -> void:
	
	var playercube := getcubepos($player.position)
	match killmaze.get_cell_tid(playercube):
		6,7,9:
			settidcube(playercube, 41, 40, 5)
			# gain 1 point (this is a 'good')
		
		# these aren't good. no points.
		# it's just visual feedback.
		46: settidcube(playercube, 56, 46, 5)
		47: settidcube(playercube, 57, 47, 5)
		04: settidcube(playercube, 54, 04, 5)
			
		#6: settidcube(playercube, 41, 46, 5)
		#7: settidcube(playercube, 41, 47, 5)
		# gain 1 point?
	
	$deathbank.spawn("deathrect").setup()
	phase -= 1
	if phase == 120:
		for cell in killmaze.get_used_cells_by_tids([9]):
			if randf() < 0.4:
				settidcube(cell, 6 + randi()%2)
		for cell in killmaze.get_used_cells_by_tids([40]):
			if randf() < 0.4:
				settidcube(cell, 46 + randi()%2)
	elif phase > 10 and phase < 120 and phase % 10 == 0:
		for cell in killmaze.get_used_cells_by_tids([6,7]):
			if randf() < 0.1:
				settidcube(cell, 6)
			if randf() < 0.1:
				settidcube(cell, 4)
			if randf() < 0.1:
				settidcube(cell, 9)
		for cell in killmaze.get_used_cells_by_tids([46,47,56,57]):
			if randf() < 0.1:
				settidcube(cell, 46)
			if randf() < 0.1:
				settidcube(cell, 4)
			if randf() < 0.1:
				settidcube(cell, 40)
	elif phase == 10:
		for cell in killmaze.get_used_cells_by_tids([6,46,56]):
			settidcube(cell, 4)
		for cell in killmaze.get_used_cells_by_tids([7]):
			settidcube(cell, 9)
		for cell in killmaze.get_used_cells_by_tids([47,57]):
			settidcube(cell, 40) # go back to blue
		# all cleared
	elif phase == 5:
		for cell in killmaze.get_used_cells_by_tids([4, 54]):
			settidcube(cell, 5)
	elif phase <= 0:
		for cell in killmaze.get_used_cells_by_tids([3]):
			settidcube(cell, 9)
		for cell in killmaze.get_used_cells_by_tids([5]):
			settidcube(cell, 3)
		#for cell in killmaze.get_used_cells_by_tids([50]):
			#settidcube(cell, 9)
		phase = 200 + randi() % 100
