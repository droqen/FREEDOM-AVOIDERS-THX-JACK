extends Node2D

var phase : int = 150

var start_anim_timer : int = 0

var chaser : Vector2i = Vector2i(8,3)*2 # 16,6
var chaser_timer : int = 100
var chaser_accel : int = 0
var chaser_last_move : Vector2i
var chaser_straight_line_accel : int = 0

var score : int = 0
func gain_point() -> void:
	score += 1
	Dreamer.w("last_score", score)
	$ScoreLabel.text = get_score_string(score)
	if score > Dreamer.r("high_score", 0):
		Dreamer.w("high_score", score)
		$HighScoreLabel.text = get_score_string(score, ' ')
func get_score_string(_score,fillchar='|',lastchar='|') -> String:
	var t : String = ''
	for i in range(_score-1):
		t += fillchar
		if i % 48 == 47: t += '\n'
	if _score > 0: t += lastchar
	return t

@onready var player = $player
@onready var killmaze : Maze = $KillMaze
@onready var chasermaze : Maze = $ChaserMaze

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
	var file : FileAccess
	file = FileAccess.open("user://last_score", FileAccess.READ)
	if file:
		var last_score_str := file.get_as_text()
		if last_score_str.is_valid_hex_number():
			Dreamer.w("last_score", int(last_score_str))
		file.close()
	
	file = FileAccess.open("user://high_score", FileAccess.READ)
	if file:
		var high_score_str := file.get_as_text()
		if high_score_str.is_valid_hex_number():
			Dreamer.w("high_score", int(high_score_str))
		assert(high_score_str == ''
			or high_score_str.is_valid_hex_number(),
			"Invalid high score value %s" % high_score_str)
		file.close()
	
	$ScoreLabel.text = get_score_string(Dreamer.r("last_score",0))
	$HighScoreLabel.text = get_score_string(Dreamer.r("high_score",0),' ')
	for cell in killmaze.get_used_cells():
		match killmaze.get_cell_tid(cell):
			3: settidcube(cell, 3)
			6: settidcube(cell, 9)
			_: settidcube(cell, -1)

func chaser_select_possibilities(possibilities:Array[Vector2i], anydir:Array[Vector2i]) -> void:
	var priorities : Array = []
	for poss in possibilities: # prefer to eat
		priorities.append(1)
		#match killmaze.get_cell_tid(poss):
			#40,41:  priorities.append(10)
			#47,57:  priorities.append( 9)
			#46,56:  priorities.append( 8)
			#46,56:  priorities.append( 7)
			#9:      priorities.append( 1)
			#_:      priorities.append( 0)
	for poss in anydir:
		priorities.append(0) # meh
	possibilities += anydir
	var highest_priority_index : int = 0
	var highest_priority : int = 0
	for i in len(priorities):
		if priorities[i] > highest_priority:
			highest_priority = priorities[i]
			highest_priority_index = i
	var dir := possibilities[highest_priority_index] - chaser
	
	if dir == chaser_last_move:
		chaser_straight_line_accel += 1
	else:
		chaser_last_move = dir
		chaser_straight_line_accel = 0
	
	chaser = possibilities[highest_priority_index]
	
	
	# clear green -> black
	var ate : bool = false
	match killmaze.get_cell_tid(chaser):
		40,41,50:  settidcube(chaser, 9); ate=true;
		46,56:     settidcube(chaser, 6); ate=true;
		47,57:     settidcube(chaser, 7); ate=true;
	
	if ate: pass # ate isn't used
	if chaser_accel < 20:
		chaser_accel += 5
	elif chaser_accel < 35:
		chaser_accel += 3
	elif chaser_accel < 55:
		chaser_accel += 1
	chaser_timer = 100 - chaser_accel - 5 * chaser_straight_line_accel
	#
	#if ate:
		#if chaser_accel < 10:
			#chaser_accel += 5
		#elif chaser_accel < 14:
			#chaser_accel += 3
		#elif chaser_accel < 19:
			#chaser_accel += 1
		#chaser_timer = 30 - chaser_accel
	#else:
		#chaser_accel = 0
		#chaser_timer = 50 - chaser_accel

	for d in [[0,0],[1,0],[1,1],[0,1]]:
		chasermaze.set_cell_tid(Vector2i(chaser.x+d[0],chaser.y+d[1]),80)

func _physics_process(_delta: float) -> void:
	
	if start_anim_timer < 80:
		if Pin.get_dpad() or Pin.get_action_held():
			start_anim_timer += 1
		elif start_anim_timer > 0:
			start_anim_timer -= 1
		player.spawning = start_anim_timer
		var t := 0
		if start_anim_timer > 20: t += 1
		if start_anim_timer > 40: t += 1
		if start_anim_timer > 58: t += 1
		if start_anim_timer > 70: t += 1
		var asm = $AnimStartMaze
		asm.show()
		for cell in killmaze.get_used_cells_by_tids([3]):
			if t == 0: asm.set_cell_tid(cell, 19)
			else: asm.set_cell_tid(cell, 99-t+1)
		for cell in chasermaze.get_used_cells_by_tids([80]):
			if t == 0: asm.set_cell_tid(cell, 19)
			else: asm.set_cell_tid(cell, 79-t+1)
		$ScoreLabel.visible_ratio = 1 - (start_anim_timer / 80.0)
		if start_anim_timer >= 80:
			asm.queue_free()
			$ScoreLabel.text = ''
			$ScoreLabel.visible_ratio = 1
		return
	
	var noplayer : bool = not is_instance_valid(player) or player.dying > 15
	
	chaser_timer -= 1
	
	if chaser_timer % 10 == 0:
		for cell in chasermaze.get_used_cells_by_tids([   81,82,83,]):
			match chasermaze.get_cell_tid(cell):
				#80: chasermaze.set_cell_tid(cell, 81)
				81: chasermaze.set_cell_tid(cell, 82)
				82: chasermaze.set_cell_tid(cell, 83)
				83: chasermaze.set_cell_tid(cell, -1)
	
	if noplayer:
		for cell in chasermaze.get_used_cells_by_tids([80]):
			chasermaze.set_cell_tid(cell, 81)
	else:
		var playercube := getcubepos(player.position)
		
		if playercube == chaser:
			player.chaser_overlap()
		
		if chaser_timer <= 0:
			#chasermaze.clear()
			for cell in chasermaze.get_used_cells_by_tids([80,         ]):
				match chasermaze.get_cell_tid(cell):
					80: chasermaze.set_cell_tid(cell, 81)
					#81: chasermaze.set_cell_tid(cell, 82)
					#82: chasermaze.set_cell_tid(cell, 83)
					#83: chasermaze.set_cell_tid(cell, -1)
					
			var randomdir : Array[Vector2i] = [
				chaser + Vector2i(2,0), chaser + Vector2i(-2,0),
				chaser + Vector2i(0,2), chaser + Vector2i(0,-2),
			]
			randomdir.shuffle()
			
			if playercube.x != chaser.x and playercube.y != chaser.y:
				var possibilities : Array[Vector2i] = [
					chaser + Vector2i.RIGHT*2*sign(playercube.x-chaser.x),
					chaser + Vector2i.DOWN *2*sign(playercube.y-chaser.y),
				]
				if (playercube.x - chaser.x) * (playercube.y - chaser.y) > 0:
					 # i think this goes ccw: player-hostile
					possibilities.reverse()
				chaser_select_possibilities(possibilities, randomdir)
			elif playercube.x == chaser.x or playercube.y == chaser.y:
				chaser_select_possibilities([chaser + 2 * Vector2i(
					sign(playercube.x - chaser.x),
					sign(playercube.y - chaser.y),
				)], randomdir)
			else:
				pass
				#chaser_select_possibilities([], randomdir)
		
		
		if player.hurting:
			if player.justhurt:
				var player_to_chaser = Vector2(chaser-playercube).normalized()
				player.vx = player_to_chaser.x
				player.vy = player_to_chaser.y
			player.position += Vector2(player.vx, player.vy)
		elif playercube == chaser:
			player.chaser_overlap()
		else:
			match killmaze.get_cell_tid(playercube):
				6,7,9:
					settidcube(playercube, 41, 40, 5)
					# gain 1 point (this is a 'good')
					gain_point()
				
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
	if noplayer and phase > 120:
		phase -= 10
	elif phase == 120:
		if noplayer:
			pass
		else:
			for cell in killmaze.get_used_cells_by_tids([9]):
				if randf() < 0.4:
					settidcube(cell, 6 + randi()%2)
			for cell in killmaze.get_used_cells_by_tids([40]):
				if randf() < 0.4:
					settidcube(cell, 46 + randi()%2)
	elif phase > 10 and phase < 120:
		if noplayer:
			if phase > 40: phase = 40
		elif phase % 10 == 0:
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
		#if phase == 60:
			#for cell in killmaze.get_used_cells_by_tids([3,96,97,98,99,]):
				#settidcube(cell, 96)
		#if phase == 49:
			#for cell in killmaze.get_used_cells_by_tids([3,96,97,98,99,]):
				#settidcube(cell, 97, 3, 5)
		if phase == 40:
			for cell in killmaze.get_used_cells_by_tids([3,96,97,98,99,]):
				settidcube(cell, 96)
			if noplayer:
				for cell in killmaze.get_used_cells_by_tids([40]):
					settidcube(cell, 86)
		if phase == 29:
			for cell in killmaze.get_used_cells_by_tids([3,96,97,98,99,]):
				settidcube(cell, 97)
			for cell in killmaze.get_used_cells_by_tids([  86,87,88,89,]):
				settidcube(cell, 87)
		if phase == 19:
			for cell in killmaze.get_used_cells_by_tids([3,96,97,98,99,]):
				settidcube(cell, 98)
			for cell in killmaze.get_used_cells_by_tids([  86,87,88,89,]):
				settidcube(cell, 88)
		if phase == 13:
			for cell in killmaze.get_used_cells_by_tids([3,96,97,98,99,]):
				settidcube(cell, 99)
			for cell in killmaze.get_used_cells_by_tids([  86,87,88,89,]):
				settidcube(cell, 89)
	elif phase == 10:
		for cell in killmaze.get_used_cells_by_tids([3,23,86,87,88,89,96,97,98,99,]):
			settidcube(cell, 9)
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
		
		if noplayer and not killmaze.get_used_cells_by_tids([3]):
			# save.
			var file : FileAccess
			file = FileAccess.open("user://last_score", FileAccess.WRITE)
			file.store_string(str(Dreamer.r("last_score")))
			file.close()
			file = FileAccess.open("user://high_score", FileAccess.WRITE)
			file.store_string(str(Dreamer.r("high_score")))
			file.close()
			Dreamer.dreamfresh(load("res://dances/01_untitled/01_untitled_Dream.tres"))
		
		phase = 200 + randi() % 100
