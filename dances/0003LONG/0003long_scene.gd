extends Node2D

@onready var player = $ylwplr
@onready var maze = $maze

func _ready() -> void:
	#player.jumped.connect(delete_pillars_behind_player)
	player.untouched.connect(delete_pillar_in_dir)

func create_pillar_x(x:int, h:int):
	for y in 10:
		var yh := 10-y
		var t := 0
		if yh == h: t = 1
		if yh < h: t = 2
		maze.set_cell_tid(Vector2i(x,y), t)
func delete_pillar_x(x:int):
	for y in 10:
		maze.set_cell_tid(Vector2i(x,y), 0)
func delete_pillar_in_dir(dir:Vector2i):
	if dir.y > 0:
		for x in [
			maze.local_to_map(player.position + Vector2(5,0)).x,
			maze.local_to_map(player.position               ).x,
			maze.local_to_map(player.position - Vector2(5,0)).x,
		]: delete_pillar_x(x)
	#elif dir.x:
		#delete_pillar_x(maze.local_to_map(player.position + 5*Vector2(dir)).x)
func delete_pillars_behind_player():
	var pcell : Vector2i = maze.local_to_map(player.position)
	for y in 10:
		for x in range(2, pcell.x+1):
			maze.set_cell_tid(Vector2i(x,y), 0)

func _physics_process(_delta: float) -> void:
	if player.position.x >= 210:
		delete_pillars_behind_player()
		player.position.x -= 210
		# regen pillars - nine
		var pillars : Array[int] = [2]
		create_pillar_x(1, 2)
		for j in 9:
			var h := randi_range(2,pillars[j]+2)
			create_pillar_x(3 + 2*j, h)
			pillars.append(h)
